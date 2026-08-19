import '../models/alphabet.dart';
import '../models/space_mode.dart';

/// Builds a substitution map and transforms text while preserving letter case.
abstract class CipherEngine {
  /// When true, plaintext and ciphertext use different symbol sets
  /// (Morse, Braille, etc.).
  bool get isEncoding => false;

  /// Alphabet used to filter / click-insert into the ciphertext field.
  Alphabet cipherSideAlphabet(Alphabet plainAlphabet) => plainAlphabet;

  /// Preview alphabet shown in the UI (monoalphabetic mapping when applicable).
  String buildCipherAlphabet(Alphabet alphabet);

  /// Optional multi-character tokens shown as clickable chips on the cipher side
  /// (e.g. Morse letter codes). When null, [buildCipherAlphabet] chars are used.
  List<String>? cipherInsertTokens(Alphabet alphabet) => null;

  Map<String, String> encryptMap(Alphabet alphabet) {
    final original = alphabet.chars;
    final cipher = _charsOf(buildCipherAlphabet(alphabet));
    final map = <String, String>{};
    final n = original.length < cipher.length ? original.length : cipher.length;
    for (var i = 0; i < n; i++) {
      map[original[i]] = cipher[i];
    }
    return map;
  }

  Map<String, String> decryptMap(Alphabet alphabet) {
    final original = alphabet.chars;
    final cipher = _charsOf(buildCipherAlphabet(alphabet));
    final map = <String, String>{};
    final n = original.length < cipher.length ? original.length : cipher.length;
    for (var i = 0; i < n; i++) {
      map[cipher[i]] = original[i];
    }
    return map;
  }

  String encrypt(
    String text,
    Alphabet alphabet, {
    SpaceMode spaceMode = SpaceMode.keep,
  }) {
    return _withSpaceMode(text, spaceMode, (chunk) => encryptChunk(chunk, alphabet));
  }

  String decrypt(
    String text,
    Alphabet alphabet, {
    SpaceMode spaceMode = SpaceMode.keep,
  }) {
    return _withSpaceMode(text, spaceMode, (chunk) => decryptChunk(chunk, alphabet));
  }

  String encryptChunk(String text, Alphabet alphabet) {
    return mapText(text, encryptMap(alphabet), alphabet, passSpaces: true);
  }

  String decryptChunk(String text, Alphabet alphabet) {
    return mapText(text, decryptMap(alphabet), alphabet, passSpaces: true);
  }

  String _withSpaceMode(
    String text,
    SpaceMode mode,
    String Function(String chunk) transform,
  ) {
    if (mode != SpaceMode.perWord) return transform(text);
    final parts = text.split(' ');
    return parts.map((p) => p.isEmpty ? '' : transform(p)).join(' ');
  }

  String mapText(
    String text,
    Map<String, String> map,
    Alphabet alphabet, {
    bool passSpaces = true,
  }) {
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (char == ' ') {
        if (passSpaces) buffer.write(' ');
        continue;
      }
      final idx = alphabet.indexOfChar(char);
      if (idx < 0) continue;
      final key = alphabet.chars[idx];
      final mapped = map[key];
      if (mapped == null) continue;
      buffer.write(preserveCase(char, mapped));
    }
    return buffer.toString();
  }

  String preserveCase(String source, String target) {
    if (source.toUpperCase() == source &&
        source.toLowerCase() != source &&
        target.toUpperCase() != target.toLowerCase()) {
      return target.toUpperCase();
    }
    return target;
  }

  /// Filters input so only alphabet letters remain (optionally keeps spaces).
  String filterInput(
    String text,
    Alphabet alphabet, {
    bool allowSpaces = true,
  }) {
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (char == ' ') {
        if (allowSpaces) buffer.write(' ');
        continue;
      }
      if (alphabet.containsChar(char)) {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  /// Filters ciphertext for encoding ciphers (output alphabet).
  String filterCipherInput(
    String text,
    Alphabet plainAlphabet, {
    bool allowSpaces = true,
  }) {
    return filterInput(
      text,
      cipherSideAlphabet(plainAlphabet),
      allowSpaces: allowSpaces,
    );
  }

  List<String> _charsOf(String s) =>
      s.runes.map((r) => String.fromCharCode(r)).toList();

  String shiftAlphabet(Alphabet alphabet, int shift) {
    final chars = alphabet.chars;
    if (chars.isEmpty) return '';
    final n = chars.length;
    final normalized = ((shift % n) + n) % n;
    return [...chars.skip(normalized), ...chars.take(normalized)].join();
  }
}

int mod(int a, int n) => ((a % n) + n) % n;

int gcd(int a, int b) {
  var x = a.abs();
  var y = b.abs();
  while (y != 0) {
    final t = x % y;
    x = y;
    y = t;
  }
  return x;
}

int? modInverse(int a, int n) {
  final aa = mod(a, n);
  if (gcd(aa, n) != 1) return null;
  for (var i = 1; i < n; i++) {
    if ((aa * i) % n == 0) continue;
    if ((aa * i) % n == 1) return i;
  }
  return null;
}
