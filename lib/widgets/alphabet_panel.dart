import 'package:flutter/material.dart';

import '../theme/shifer_theme.dart';

class AlphabetPanel extends StatelessWidget {
  final String title;
  final String letters;
  final List<String>? tokens;
  final ValueChanged<String>? onInsert;
  final String? hint;

  const AlphabetPanel({
    super.key,
    required this.title,
    required this.letters,
    this.tokens,
    this.onInsert,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final items = tokens ??
        letters.runes.map((r) => String.fromCharCode(r)).toList();

    // Multi-char tokens (Morse codes, NATO words…) get one uniform chip size
    // so the panel reads as a compact alphabet grid instead of a ragged mix.
    double? chipWidth;
    if (tokens != null) {
      var maxLen = 1;
      for (final t in items) {
        final l = t.runes.length;
        if (l > maxLen) maxLen = l;
      }
      chipWidth = (maxLen * 7.0 + 16).clamp(30.0, 64.0);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: ShiferTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ShiferTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ShiferTheme.muted,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 2),
            Text(
              hint!,
              style: TextStyle(fontSize: 11, color: ShiferTheme.muted),
            ),
          ],
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (final item in items)
                    _LetterChip(
                      label: item,
                      width: chipWidth,
                      onTap: onInsert == null ? null : () => onInsert!(item),
                    ),
                  if (onInsert != null)
                    _LetterChip(
                      label: '␣',
                      tooltip: 'space',
                      width: chipWidth,
                      onTap: () => onInsert!(' '),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LetterChip extends StatelessWidget {
  final String label;
  final String? tooltip;
  final VoidCallback? onTap;
  final double? width;

  const _LetterChip({
    required this.label,
    this.onTap,
    this.tooltip,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final display = label == ' ' ? '␣' : label;
    final wide = display.length > 2;
    final fixed = width != null;
    final child = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          width: width ?? (wide ? null : 30),
          height: 30,
          padding: width != null
              ? EdgeInsets.zero
              : (wide
                  ? const EdgeInsets.symmetric(horizontal: 8)
                  : EdgeInsets.zero),
          decoration: BoxDecoration(
            color: onTap == null
                ? ShiferTheme.surface
                : ShiferTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: onTap == null ? ShiferTheme.border : ShiferTheme.primary,
            ),
          ),
          child: Center(
            child: Text(
              display.length == 1 ? display.toUpperCase() : display,
              style: TextStyle(
                fontSize: fixed ? 12 : (wide ? 11 : 13),
                fontWeight: FontWeight.w600,
                color: ShiferTheme.text,
              ),
            ),
          ),
        ),
      ),
    );

    if (tooltip != null || onTap != null) {
      return Tooltip(
        message: tooltip ?? (label == ' ' ? 'space' : label),
        child: child,
      );
    }
    return child;
  }
}
