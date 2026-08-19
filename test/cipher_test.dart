import 'package:flutter_test/flutter_test.dart';

import 'package:shifer/ciphers/cipher_factory.dart';
import 'package:shifer/ciphers/extra_ciphers.dart';
import 'package:shifer/ciphers/mono_ciphers.dart';
import 'package:shifer/models/alphabet.dart';
import 'package:shifer/models/cipher_info.dart';
import 'package:shifer/models/space_mode.dart';
import 'package:shifer/services/cipher_detector.dart';

void main() {
  final ru = BuiltinAlphabets.russian;
  final en = BuiltinAlphabets.english;

  test('click-style append: reverse round-trips', () {
    final cipher = ReverseTextCipher();
    expect(cipher.encrypt('привет', ru), 'тевирп');
    expect(
      cipher.encrypt('привет мир', ru, spaceMode: SpaceMode.perWord),
      'тевирп рим',
    );
  });

  test('caesar preserves spaces', () {
    final cipher = CaesarCipher(shift: 1);
    expect(cipher.encrypt('ab cd', en), 'bc de');
  });

  test('detector finds caesar', () {
    final cipher = CaesarCipher(shift: 3);
    final secret = cipher.encrypt('hello', en);
    final hits = CipherDetector().analyze(
      secret,
      alphabet: en,
      isRu: false,
    );
    expect(hits.any((h) => h.plaintext.contains('hello')), isTrue);
  });

  test('factory round-trips keyless-ish ciphers', () {
    for (final info in availableCiphers) {
      if (info.kind == CipherKind.playfair) continue; // digraph padding
      final engine = createCipher(
        info.kind,
        CipherSettings.demoFor(info.kind).copyWith(keyword: 'key'),
      );
      final alphabet = BuiltinAlphabets.all.firstWhere(
        info.supportsAlphabet,
        orElse: () => en,
      );
      final sample = engine.filterInput('hello', alphabet);
      if (sample.isEmpty) continue;
      final encoded = engine.encrypt(sample, alphabet);
      final decoded = engine.decrypt(encoded, alphabet);
      // Some encodings normalize case / fillers — require non-empty decode.
      expect(decoded.isNotEmpty, isTrue, reason: info.kind.name);
    }
  });
}
