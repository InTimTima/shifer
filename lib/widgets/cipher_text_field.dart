import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/alphabet.dart';

class AlphabetInputFormatter extends TextInputFormatter {
  final Alphabet alphabet;
  final bool allowSpaces;
  final Set<String>? extraAllowed;

  AlphabetInputFormatter(
    this.alphabet, {
    this.allowSpaces = true,
    this.extraAllowed,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final filtered = StringBuffer();
    for (final rune in newValue.text.runes) {
      final char = String.fromCharCode(rune);
      if (char == ' ') {
        if (allowSpaces) filtered.write(char);
        continue;
      }
      if (alphabet.containsChar(char) ||
          (extraAllowed != null && extraAllowed!.contains(char))) {
        filtered.write(char);
      }
    }
    final text = filtered.toString();
    // Try to keep caret near the end if content shrank; otherwise clamp.
    final offset = newValue.selection.baseOffset.clamp(0, text.length);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

class CipherTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hint;
  final Alphabet alphabet;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final bool allowSpaces;
  final Set<String>? extraAllowed;

  const CipherTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.alphabet,
    required this.onChanged,
    this.focusNode,
    this.enabled = true,
    this.allowSpaces = true,
    this.extraAllowed,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      onChanged: onChanged,
      inputFormatters: [
        AlphabetInputFormatter(
          alphabet,
          allowSpaces: allowSpaces,
          extraAllowed: extraAllowed,
        ),
      ],
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
      ),
      style: const TextStyle(fontSize: 16, letterSpacing: 0.4),
    );
  }
}

/// Appends [value] to the field (or inserts at a sane caret if still focused).
/// Avoids the common desktop bug where an unfocused field reports a
/// full-selection / invalid range and a chip click would replace all text.
void insertTextAtSelection(
  TextEditingController controller,
  String value, {
  int? preferredOffset,
}) {
  final text = controller.text;
  final selection = controller.selection;

  var start = text.length;
  var end = text.length;

  if (preferredOffset != null &&
      preferredOffset >= 0 &&
      preferredOffset <= text.length) {
    start = preferredOffset;
    end = preferredOffset;
  } else if (selection.isValid &&
      selection.start >= 0 &&
      selection.end >= 0 &&
      selection.start <= text.length &&
      selection.end <= text.length &&
      // Ignore accidental "select all" when inserting from chips.
      !(selection.start == 0 &&
          selection.end == text.length &&
          text.isNotEmpty)) {
    start = selection.start;
    end = selection.end;
  }

  final newText = text.replaceRange(start, end, value);
  controller.value = TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(offset: start + value.length),
  );
}
