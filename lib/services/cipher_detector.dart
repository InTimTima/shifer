import '../ciphers/cipher_factory.dart';
import '../ciphers/mono_ciphers.dart';
import '../models/alphabet.dart';
import '../models/cipher_info.dart';
import '../models/space_mode.dart';
import 'word_list.dart';

class DetectionHit {
  final CipherInfo info;
  final String plaintext;
  final double score;
  final String detail;

  const DetectionHit({
    required this.info,
    required this.plaintext,
    required this.score,
    required this.detail,
  });
}

/// Lightweight classical cipher identifier.
///
/// Feasible on phones: for short messages it tries keyless transforms and
/// brute-forces Caesar/ROT/rail diameters. Keyed ciphers are only probed with
/// a small common-key list + “needs key” hint — full cryptanalysis would be
/// a different product.
class CipherDetector {
  static const _commonKeysRu = ['ключ', 'шифр', 'пароль', 'секрет', 'код'];
  static const _commonKeysEn = ['key', 'cipher', 'password', 'secret', 'code'];

  List<DetectionHit> analyze(
    String ciphertext, {
    required Alphabet alphabet,
    required bool isRu,
  }) {
    final input = ciphertext.trim();
    if (input.isEmpty) return [];

    final hits = <DetectionHit>[];
    final keys = isRu ? _commonKeysRu : _commonKeysEn;

    void consider(CipherInfo info, String plain, String detail, {double boost = 0}) {
      if (plain.trim().isEmpty) return;
      if (plain == input) return;
      final score = _score(plain, alphabet, isRu) + boost;
      if (score < 0.05) return;
      final stats = _dictStats(plain, isRu);
      var detailOut = detail;
      if (stats.found > 0) {
        final wordsLabel = stats.matched.take(6).join(' ');
        detailOut = isRu
            ? '$detail · слова: ${stats.found}/${stats.total} · $wordsLabel'
            : '$detail · words: ${stats.found}/${stats.total} · $wordsLabel';
      }
      hits.add(DetectionHit(
        info: info,
        plaintext: plain,
        score: score,
        detail: detailOut,
      ));
    }

    CipherInfo infoOf(CipherKind kind) =>
        availableCiphers.firstWhere((c) => c.kind == kind);

    // Keyless / fixed
    for (final kind in [
      CipherKind.mirror,
      CipherKind.rotHalf,
      CipherKind.oddEven,
      CipherKind.reverseText,
      CipherKind.trithemius,
      CipherKind.rot47,
      CipherKind.morse,
      CipherKind.braille,
      CipherKind.a1z26,
      CipherKind.bacon,
      CipherKind.polybius,
      CipherKind.binary,
      CipherKind.hex,
      CipherKind.base64,
      CipherKind.tapCode,
    ]) {
      final info = infoOf(kind);
      if (!info.supportsAlphabet(alphabet) && kind != CipherKind.rot47) {
        continue;
      }
      final engine = createCipher(kind, CipherSettings.demoFor(kind));
      try {
        final plain = engine.decrypt(input, alphabet);
        consider(info, plain, 'без ключа');
      } catch (_) {}
    }

    // Caesar brute force
    final caesarInfo = infoOf(CipherKind.caesar);
    final n = alphabet.length;
    for (var shift = 0; shift < n; shift++) {
      final engine = CaesarCipher(shift: shift);
      final plain = engine.decrypt(input, alphabet);
      consider(
        caesarInfo,
        plain,
        'сдвиг $shift',
        boost: shift == 3 ? 0.05 : 0,
      );
    }

    // Rail fence diameters 2..6
    final railInfo = infoOf(CipherKind.railFence);
    for (var r = 2; r <= 6; r++) {
      final engine = createCipher(CipherKind.railFence, CipherSettings(rails: r));
      final plain = engine.decrypt(input, alphabet, spaceMode: SpaceMode.keep);
      consider(railInfo, plain, 'рельсов: $r');
    }

    // Scytale diameters
    final scytaleInfo = infoOf(CipherKind.scytale);
    for (var d = 2; d <= 8; d++) {
      final engine =
          createCipher(CipherKind.scytale, CipherSettings(diameter: d));
      final plain = engine.decrypt(input, alphabet);
      consider(scytaleInfo, plain, 'диаметр $d');
    }

    // Keyed ciphers with common keys only
    for (final kind in [
      CipherKind.vigenere,
      CipherKind.beaufort,
      CipherKind.keywordCaesar,
      CipherKind.xor,
      CipherKind.columnar,
      CipherKind.playfair,
    ]) {
      final info = infoOf(kind);
      for (final key in keys) {
        final filteredKey = key.runes
            .map(String.fromCharCode)
            .where(alphabet.containsChar)
            .join();
        if (filteredKey.isEmpty) continue;
        final engine = createCipher(
          kind,
          CipherSettings(keyword: filteredKey),
        );
        try {
          final plain = engine.decrypt(input, alphabet);
          consider(info, plain, 'ключ «$filteredKey»', boost: 0.02);
        } catch (_) {}
      }
    }

    hits.sort((a, b) => b.score.compareTo(a.score));

    // Deduplicate by plaintext
    final seen = <String>{};
    final unique = <DetectionHit>[];
    for (final h in hits) {
      final key = '${h.info.kind.name}|${h.plaintext}';
      if (seen.add(key)) unique.add(h);
      if (unique.length >= 24) break;
    }
    return unique;
  }

  double _score(String text, Alphabet alphabet, bool isRu) {
    if (text.isEmpty) return 0;
    final letters = text.runes
        .map(String.fromCharCode)
        .where((c) => c != ' ' && alphabet.containsChar(c))
        .toList();
    if (letters.isEmpty) return 0;

    final lower = text.toLowerCase();
    var score = 0.0;

    // Common words
    final words = isRu
        ? const ['и', 'в', 'не', 'на', 'что', 'это', 'привет', 'да', 'нет', 'как']
        : const ['the', 'and', 'to', 'of', 'is', 'hello', 'you', 'in', 'that'];
    for (final w in words) {
      if (lower.contains(w)) score += 0.12;
    }

    // Vowel ratio heuristic
    final vowels = isRu ? 'аеёиоуыэюя' : 'aeiouy';
    var vowelCount = 0;
    for (final c in letters) {
      if (vowels.contains(c.toLowerCase())) vowelCount++;
    }
    final ratio = vowelCount / letters.length;
    if (ratio > 0.25 && ratio < 0.55) score += 0.25;

    // Prefer outputs that stay in alphabet mostly
    final kept = letters.length / text.replaceAll(' ', '').length.clamp(1, 9999);
    score += 0.2 * kept;

    // A real decryption reads like a language: reward known dictionary words.
    final stats = _dictStats(text, isRu);
    if (stats.total > 0) {
      final dictRatio = stats.found / stats.total;
      score += 0.5 * dictRatio;
      if (dictRatio == 1 && stats.total >= 2) score += 0.2;
    }

    // Penalize very short
    if (letters.length < 2) score *= 0.3;

    return score;
  }

  static const _ruEndings = [
    'ого', 'его', 'ому', 'ему', 'ыми', 'ими', 'ого',
    'ая', 'яя', 'ое', 'ее', 'ые', 'ие', 'ой', 'ий',
    'а', 'я', 'о', 'е', 'ы', 'и', 'у', 'ю', 'ь',
  ];
  static const _enEndings = [
    'ing', 'ies', 'ies', 'ed', 'es', 'er', 'est', 'ly', 's',
  ];

  /// True if the word (or a plausible stem) is a known dictionary word.
  bool _matchesDict(String w, Set<String> dict, bool isRu) {
    if (dict.contains(w)) return true;
    final endings = isRu ? _ruEndings : _enEndings;
    for (final end in endings) {
      if (w.length > end.length + 2 && w.endsWith(end)) {
        if (dict.contains(w.substring(0, w.length - end.length))) return true;
      }
    }
    return false;
  }

  ({int found, int total, List<String> matched}) _dictStats(
    String text,
    bool isRu,
  ) {
    final dict = isRu ? WordList.ru : WordList.en;
    final words = text.toLowerCase().split(RegExp(r'[\s\d/|.\-]+'));
    var found = 0;
    var total = 0;
    final matched = <String>[];
    for (final w in words) {
      if (w.runes.length < 3) continue;
      total++;
      if (_matchesDict(w, dict, isRu)) {
        found++;
        if (!matched.contains(w)) matched.add(w);
      }
    }
    return (found: found, total: total, matched: matched);
  }
}
