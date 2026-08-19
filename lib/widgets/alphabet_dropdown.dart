import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/alphabet.dart';
import '../services/app_settings.dart';
import '../theme/shifer_theme.dart';

Future<Alphabet?> showCustomAlphabetDialog({
  required BuildContext context,
  required AppStrings strings,
  required AppSettings settings,
}) {
  return showDialog<Alphabet>(
    context: context,
    builder: (context) => _CustomAlphabetDialog(
      strings: strings,
      settings: settings,
    ),
  );
}

class _CustomAlphabetDialog extends StatefulWidget {
  final AppStrings strings;
  final AppSettings settings;

  const _CustomAlphabetDialog({
    required this.strings,
    required this.settings,
  });

  @override
  State<_CustomAlphabetDialog> createState() => _CustomAlphabetDialogState();
}

class _CustomAlphabetDialogState extends State<_CustomAlphabetDialog> {
  final _nameController = TextEditingController();
  final _lettersController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _lettersController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final raw = _lettersController.text.trim();
    if (name.isEmpty || raw.isEmpty) {
      setState(() => _error = widget.strings.alphabetErrorEmpty);
      return;
    }

    final seen = <String>{};
    final unique = StringBuffer();
    for (final rune in raw.runes) {
      final char = String.fromCharCode(rune).toLowerCase();
      if (char.trim().isEmpty) continue;
      if (!seen.add(char)) {
        setState(() => _error = widget.strings.alphabetErrorDuplicate);
        return;
      }
      unique.write(char);
    }

    if (unique.isEmpty) {
      setState(() => _error = widget.strings.alphabetErrorEmpty);
      return;
    }

    final alphabet = Alphabet(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      nameKey: name,
      letters: unique.toString(),
      category: AlphabetCategory.custom,
      isCustom: true,
    );
    widget.settings.addCustomAlphabet(alphabet);
    Navigator.of(context).pop(alphabet);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    return AlertDialog(
      title: Text(s.newAlphabetTitle),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: s.alphabetName),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lettersController,
              decoration: InputDecoration(labelText: s.alphabetLetters),
              maxLines: 3,
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(s.save),
        ),
      ],
    );
  }
}

class AlphabetDropdown extends StatelessWidget {
  final Alphabet value;
  final List<Alphabet> alphabets;
  final AppStrings strings;
  final ValueChanged<Alphabet> onChanged;
  final VoidCallback onCreateCustom;
  final ValueChanged<Alphabet>? onDeleteCustom;

  const AlphabetDropdown({
    super.key,
    required this.value,
    required this.alphabets,
    required this.strings,
    required this.onChanged,
    required this.onCreateCustom,
    this.onDeleteCustom,
  });

  String _label(Alphabet a) => a.isCustom ? a.nameKey : strings.t(a.nameKey);

  String _categoryTitle(AlphabetCategory category) {
    switch (category) {
      case AlphabetCategory.letters:
        return strings.alphabetCatLetters;
      case AlphabetCategory.digits:
        return strings.alphabetCatDigits;
      case AlphabetCategory.mixed:
        return strings.alphabetCatMixed;
      case AlphabetCategory.custom:
        return strings.alphabetCatCustom;
    }
  }

  List<DropdownMenuItem<String>> _buildItems() {
    final items = <DropdownMenuItem<String>>[];
    const order = [
      AlphabetCategory.letters,
      AlphabetCategory.digits,
      AlphabetCategory.mixed,
      AlphabetCategory.custom,
    ];

    for (final category in order) {
      final group = alphabets.where((a) => a.category == category).toList();
      if (group.isEmpty) continue;
      items.add(
        DropdownMenuItem(
          enabled: false,
          value: '__header_${category.name}__',
          child: Text(
            _categoryTitle(category),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: ShiferTheme.primary,
            ),
          ),
        ),
      );
      for (final a in group) {
        items.add(
          DropdownMenuItem(
            value: a.id,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(_label(a), overflow: TextOverflow.ellipsis),
            ),
          ),
        );
      }
    }

    items.add(
      DropdownMenuItem(
        value: '__custom__',
        child: Text(
          strings.customAlphabet,
          style: TextStyle(
            color: ShiferTheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final itemValues = alphabets.map((a) => a.id).toSet();
    final selectedId = itemValues.contains(value.id)
        ? value.id
        : (alphabets.isNotEmpty ? alphabets.first.id : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          key: ValueKey(selectedId),
          initialValue: selectedId,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: strings.alphabetLabel,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: _buildItems(),
          onChanged: (id) {
            if (id == null) return;
            if (id == '__custom__') {
              onCreateCustom();
              return;
            }
            if (id.startsWith('__header_')) return;
            final match = alphabets.firstWhere((a) => a.id == id);
            onChanged(match);
          },
        ),
        if (value.isCustom && onDeleteCustom != null) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => onDeleteCustom!(value),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: Text(strings.delete),
            ),
          ),
        ],
      ],
    );
  }
}
