import 'package:flutter/material.dart';

import '../ciphers/cipher_factory.dart';
import '../l10n/app_strings.dart';
import '../models/alphabet.dart';
import '../models/cipher_info.dart';
import '../theme/shifer_theme.dart';

class CipherCard extends StatelessWidget {
  final CipherInfo info;
  final AppStrings strings;
  final Alphabet demoAlphabet;
  final VoidCallback onOpen;

  const CipherCard({
    super.key,
    required this.info,
    required this.strings,
    required this.demoAlphabet,
    required this.onOpen,
  });

  Alphabet _alphabetForDemo() {
    // Prefer locale-matching alphabet when compatible.
    final preferred = strings.isRu
        ? [demoAlphabet, BuiltinAlphabets.russian, BuiltinAlphabets.english]
        : [BuiltinAlphabets.english, demoAlphabet, BuiltinAlphabets.russian];
    for (final a in [...preferred, ...BuiltinAlphabets.all]) {
      if (info.supportsAlphabet(a)) return a;
    }
    return demoAlphabet;
  }

  String _demoWord(Alphabet alphabet) {
    final word = strings.exampleWord;
    final buffer = StringBuffer();
    for (final rune in word.runes) {
      final char = String.fromCharCode(rune);
      if (alphabet.containsChar(char)) buffer.write(char);
    }
    if (buffer.isNotEmpty) return buffer.toString();
    if (alphabet.category == AlphabetCategory.digits ||
        alphabet.category == AlphabetCategory.mixed) {
      return alphabet.chars.take(6).join();
    }
    if (alphabet.containsChar('h')) return 'hello';
    if (alphabet.containsChar('п')) return 'привет';
    return alphabet.chars.take(6).join();
  }

  @override
  Widget build(BuildContext context) {
    final alphabet = _alphabetForDemo();
    final settings = CipherSettings.demoFor(info.kind).copyWith(
      customCipherLetters: info.customCipherLetters ?? '',
    );
    final tuned = alphabet.containsChar('к')
        ? settings
        : settings.copyWith(
            keyword: settings.keyword.isEmpty ? '' : 'key',
          );
    final engine = createCipher(info.kind, tuned);
    final examplePlain = _demoWord(alphabet);
    final exampleCipher = engine.encrypt(examplePlain, alphabet);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 260;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  info.isUserDefined
                      ? info.nameKey
                      : strings.t(info.nameKey),
                  style: TextStyle(
                    fontSize: compact ? 18 : 22,
                    fontWeight: FontWeight.w700,
                    color: ShiferTheme.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  strings.t(_categoryKey(info.category)),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ShiferTheme.primary,
                  ),
                ),
                SizedBox(height: compact ? 6 : 10),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 56),
                    child: SingleChildScrollView(
                      child: Text(
                        strings.t(info.descriptionKey),
                        style: TextStyle(
                          fontSize: compact ? 13.5 : 15,
                          height: 1.4,
                          color: ShiferTheme.muted,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: compact ? 8 : 12),
                Container(
                  padding: EdgeInsets.all(compact ? 8 : 12),
                  decoration: BoxDecoration(
                    color: ShiferTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ShiferTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.example,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ShiferTheme.muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$examplePlain  →  $exampleCipher',
                        style: TextStyle(
                          fontSize: compact ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: ShiferTheme.text,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: compact ? 10 : 14),
                ElevatedButton(
                  onPressed: onOpen,
                  child: Text(strings.open),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _categoryKey(CipherCategory category) {
    switch (category) {
      case CipherCategory.classic:
        return 'categoryClassic';
      case CipherCategory.monoalphabetic:
        return 'categoryMono';
      case CipherCategory.polyalphabetic:
        return 'categoryPoly';
      case CipherCategory.transposition:
        return 'categoryTransposition';
      case CipherCategory.encoding:
        return 'categoryEncoding';
    }
  }
}
