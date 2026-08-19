import 'dart:convert';

import '../models/alphabet.dart';
import '../models/space_mode.dart';
import 'cipher_engine.dart';

/// Reverse the text (and optionally each word).
class ReverseTextCipher extends CipherEngine {
  @override
  String buildCipherAlphabet(Alphabet alphabet) =>
      alphabet.chars.reversed.join();

  @override
  String encryptChunk(String text, Alphabet alphabet) {
    final filtered = filterInput(text, alphabet, allowSpaces: true);
    return filtered.runes.map((r) => String.fromCharCode(r)).toList().reversed.join();
  }

  @override
  String decryptChunk(String text, Alphabet alphabet) =>
      encryptChunk(text, alphabet);
}

/// Bacon cipher: letter → 5-bit A/B (or 0/1) pattern.
class BaconCipher extends CipherEngine {
  static const _codes = {
    'a': 'aaaaa',
    'b': 'aaaab',
    'c': 'aaaba',
    'd': 'aaabb',
    'e': 'aabaa',
    'f': 'aabab',
    'g': 'aabba',
    'h': 'aabbb',
    'i': 'abaaa',
    'j': 'abaaa',
    'k': 'abaab',
    'l': 'ababa',
    'm': 'ababb',
    'n': 'abbaa',
    'o': 'abbab',
    'p': 'abbba',
    'q': 'abbbb',
    'r': 'baaaa',
    's': 'baaab',
    't': 'baaba',
    'u': 'baabb',
    'v': 'baabb',
    'w': 'babaa',
    'x': 'babab',
    'y': 'babba',
    'z': 'babbb',
  };

  @override
  bool get isEncoding => true;

  @override
  Alphabet cipherSideAlphabet(Alphabet plainAlphabet) => const Alphabet(
        id: 'bacon_out',
        nameKey: 'encodingOut',
        letters: 'ab01 ',
        category: AlphabetCategory.mixed,
      );

  @override
  String buildCipherAlphabet(Alphabet alphabet) => 'ab';

  @override
  List<String>? cipherInsertTokens(Alphabet alphabet) =>
      ['a', 'b', '0', '1', ' '];

  Map<String, String> _table(Alphabet alphabet) {
    // Map alphabet letters in order onto Bacon codes cycling Latin set.
    final latin = _codes.keys.toList();
    final map = <String, String>{};
    final chars = alphabet.chars;
    for (var i = 0; i < chars.length; i++) {
      map[chars[i]] = _codes[latin[i % latin.length]]!;
    }
    return map;
  }

  @override
  String encryptChunk(String text, Alphabet alphabet) {
    final table = _table(alphabet);
    final parts = <String>[];
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (char == ' ') {
        parts.add('/');
        continue;
      }
      final code = table[char.toLowerCase()];
      if (code != null) parts.add(code);
    }
    return parts.join(' ');
  }

  @override
  String decryptChunk(String text, Alphabet alphabet) {
    final reverse = <String, String>{
      for (final e in _table(alphabet).entries) e.value: e.key,
    };
    final normalized = text.toLowerCase().replaceAll('0', 'a').replaceAll('1', 'b');
    final words = normalized.split('/');
    final out = <String>[];
    for (final word in words) {
      final buf = StringBuffer();
      for (final token in word.trim().split(RegExp(r'\s+'))) {
        if (token.isEmpty) continue;
        final letter = reverse[token];
        if (letter != null) buf.write(letter);
      }
      out.add(buf.toString());
    }
    return out.join(' ');
  }

  @override
  String encrypt(String text, Alphabet alphabet,
          {SpaceMode spaceMode = SpaceMode.keep}) =>
      encryptChunk(text, alphabet);

  @override
  String decrypt(String text, Alphabet alphabet,
          {SpaceMode spaceMode = SpaceMode.keep}) =>
      decryptChunk(text, alphabet);
}

/// Polybius square 5×5 (I/J merge for Latin; for longer alphabets uses rows of 6).
class PolybiusCipher extends CipherEngine {
  @override
  bool get isEncoding => true;

  @override
  Alphabet cipherSideAlphabet(Alphabet plainAlphabet) => const Alphabet(
        id: 'polybius_out',
        nameKey: 'encodingOut',
        letters: '1234567890 ',
        category: AlphabetCategory.digits,
      );

  @override
  String buildCipherAlphabet(Alphabet alphabet) => '1234567890';

  @override
  List<String>? cipherInsertTokens(Alphabet alphabet) =>
      ['1', '2', '3', '4', '5', '6', ' '];

  int _side(Alphabet alphabet) {
    final n = alphabet.length;
    var side = 5;
    while (side * side < n) {
      side++;
    }
    return side;
  }

  Map<String, String> _coords(Alphabet alphabet) {
    final side = _side(alphabet);
    final map = <String, String>{};
    final chars = alphabet.chars;
    for (var i = 0; i < chars.length; i++) {
      final r = i ~/ side + 1;
      final c = i % side + 1;
      map[chars[i]] = '$r$c';
    }
    return map;
  }

  @override
  String encryptChunk(String text, Alphabet alphabet) {
    final table = _coords(alphabet);
    final parts = <String>[];
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (char == ' ') {
        parts.add('/');
        continue;
      }
      final code = table[char.toLowerCase()] ?? table[char];
      if (code != null) parts.add(code);
    }
    return parts.join(' ');
  }

  @override
  String decryptChunk(String text, Alphabet alphabet) {
    final reverse = <String, String>{
      for (final e in _coords(alphabet).entries) e.value: e.key,
    };
    final words = text.split('/');
    final out = <String>[];
    for (final word in words) {
      final buf = StringBuffer();
      for (final token in word.trim().split(RegExp(r'\s+'))) {
        if (token.isEmpty) continue;
        final letter = reverse[token];
        if (letter != null) buf.write(letter);
      }
      out.add(buf.toString());
    }
    return out.join(' ');
  }

  @override
  String encrypt(String text, Alphabet alphabet,
          {SpaceMode spaceMode = SpaceMode.keep}) =>
      encryptChunk(text, alphabet);

  @override
  String decrypt(String text, Alphabet alphabet,
          {SpaceMode spaceMode = SpaceMode.keep}) =>
      decryptChunk(text, alphabet);
}

class BinaryCipher extends CipherEngine {
  @override
  bool get isEncoding => true;

  @override
  Alphabet cipherSideAlphabet(Alphabet plainAlphabet) => const Alphabet(
        id: 'bin_out',
        nameKey: 'encodingOut',
        letters: '01 ',
        category: AlphabetCategory.digits,
      );

  @override
  String buildCipherAlphabet(Alphabet alphabet) => '01';

  @override
  List<String>? cipherInsertTokens(Alphabet alphabet) => ['0', '1', ' '];

  int _width(Alphabet alphabet) {
    var w = 1;
    var n = alphabet.length - 1;
    while (n > 1) {
      n >>= 1;
      w++;
    }
    return w < 5 ? 5 : w;
  }

  @override
  String encryptChunk(String text, Alphabet alphabet) {
    final w = _width(alphabet);
    final parts = <String>[];
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (char == ' ') {
        parts.add('/');
        continue;
      }
      final idx = alphabet.indexOfChar(char);
      if (idx < 0) continue;
      parts.add(idx.toRadixString(2).padLeft(w, '0'));
    }
    return parts.join(' ');
  }

  @override
  String decryptChunk(String text, Alphabet alphabet) {
    final words = text.split('/');
    final out = <String>[];
    for (final word in words) {
      final buf = StringBuffer();
      for (final token in word.trim().split(RegExp(r'\s+'))) {
        if (token.isEmpty) continue;
        final idx = int.tryParse(token, radix: 2);
        if (idx == null || idx < 0 || idx >= alphabet.length) continue;
        buf.write(alphabet.charAt(idx));
      }
      out.add(buf.toString());
    }
    return out.join(' ');
  }

  @override
  String encrypt(String text, Alphabet alphabet,
          {SpaceMode spaceMode = SpaceMode.keep}) =>
      encryptChunk(text, alphabet);

  @override
  String decrypt(String text, Alphabet alphabet,
          {SpaceMode spaceMode = SpaceMode.keep}) =>
      decryptChunk(text, alphabet);
}

class HexCipher extends CipherEngine {
  @override
  bool get isEncoding => true;

  @override
  Alphabet cipherSideAlphabet(Alphabet plainAlphabet) => const Alphabet(
        id: 'hex_out',
        nameKey: 'encodingOut',
        letters: '0123456789abcdef ',
        category: AlphabetCategory.mixed,
      );

  @override
  String buildCipherAlphabet(Alphabet alphabet) => '0123456789abcdef';

  @override
  List<String>? cipherInsertTokens(Alphabet alphabet) =>
      '0123456789abcdef'.split('');

  @override
  String encryptChunk(String text, Alphabet alphabet) {
    final parts = <String>[];
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (char == ' ') {
        parts.add('/');
        continue;
      }
      final idx = alphabet.indexOfChar(char);
      if (idx < 0) continue;
      parts.add(idx.toRadixString(16));
    }
    return parts.join(' ');
  }

  @override
  String decryptChunk(String text, Alphabet alphabet) {
    final words = text.split('/');
    final out = <String>[];
    for (final word in words) {
      final buf = StringBuffer();
      for (final token in word.trim().split(RegExp(r'\s+'))) {
        if (token.isEmpty) continue;
        final idx = int.tryParse(token, radix: 16);
        if (idx == null || idx < 0 || idx >= alphabet.length) continue;
        buf.write(alphabet.charAt(idx));
      }
      out.add(buf.toString());
    }
    return out.join(' ');
  }

  @override
  String encrypt(String text, Alphabet alphabet,
          {SpaceMode spaceMode = SpaceMode.keep}) =>
      encryptChunk(text, alphabet);

  @override
  String decrypt(String text, Alphabet alphabet,
          {SpaceMode spaceMode = SpaceMode.keep}) =>
      decryptChunk(text, alphabet);
}

class Base64Cipher extends CipherEngine {
  @override
  bool get isEncoding => true;

  @override
  Alphabet cipherSideAlphabet(Alphabet plainAlphabet) => const Alphabet(
        id: 'b64_out',
        nameKey: 'encodingOut',
        letters:
            'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=',
        category: AlphabetCategory.mixed,
      );

  @override
  String buildCipherAlphabet(Alphabet alphabet) =>
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';

  @override
  List<String>? cipherInsertTokens(Alphabet alphabet) => null;

  @override
  String encryptChunk(String text, Alphabet alphabet) {
    final filtered = filterInput(text, alphabet, allowSpaces: true);
    return base64.encode(utf8.encode(filtered));
  }

  @override
  String decryptChunk(String text, Alphabet alphabet) {
    try {
      final cleaned = text.replaceAll(RegExp(r'\s+'), '');
      return utf8.decode(base64.decode(cleaned), allowMalformed: true);
    } catch (_) {
      return '';
    }
  }

  @override
  String encrypt(String text, Alphabet alphabet,
          {SpaceMode spaceMode = SpaceMode.keep}) =>
      encryptChunk(text, alphabet);

  @override
  String decrypt(String text, Alphabet alphabet,
          {SpaceMode spaceMode = SpaceMode.keep}) =>
      decryptChunk(text, alphabet);
}

class XorCipher extends CipherEngine {
  final String keyword;

  XorCipher({required this.keyword});

  @override
  String buildCipherAlphabet(Alphabet alphabet) => alphabet.lower;

  List<int> _keyIdx(Alphabet alphabet) {
    final out = <int>[];
    for (final rune in keyword.runes) {
      final i = alphabet.indexOfChar(String.fromCharCode(rune));
      if (i >= 0) out.add(i);
    }
    return out.isEmpty ? [0] : out;
  }

  @override
  String encryptChunk(String text, Alphabet alphabet) {
    final n = alphabet.length;
    if (n == 0) return '';
    final key = _keyIdx(alphabet);
    final buf = StringBuffer();
    var ki = 0;
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (char == ' ') {
        buf.write(' ');
        continue;
      }
      final idx = alphabet.indexOfChar(char);
      if (idx < 0) continue;
      final out = idx ^ key[ki % key.length];
      ki++;
      buf.write(preserveCase(char, alphabet.charAt(out % n)));
    }
    return buf.toString();
  }

  @override
  String decryptChunk(String text, Alphabet alphabet) =>
      encryptChunk(text, alphabet);
}

/// ROT47 over printable ASCII — ignores selected alphabet for transform.
class Rot47Cipher extends CipherEngine {
  static const _ascii =
      r'''!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~''';

  @override
  String buildCipherAlphabet(Alphabet alphabet) => _ascii;

  @override
  Alphabet cipherSideAlphabet(Alphabet plainAlphabet) => const Alphabet(
        id: 'rot47',
        nameKey: 'encodingOut',
        letters: _ascii,
        category: AlphabetCategory.mixed,
      );

  @override
  bool get isEncoding => true;

  String _map(String text) {
    final buf = StringBuffer();
    for (final rune in text.runes) {
      final code = rune;
      if (code >= 33 && code <= 126) {
        buf.writeCharCode(33 + ((code - 33 + 47) % 94));
      } else if (code == 32) {
        buf.write(' ');
      }
    }
    return buf.toString();
  }

  @override
  String filterInput(String text, Alphabet alphabet, {bool allowSpaces = true}) {
    final buf = StringBuffer();
    for (final rune in text.runes) {
      if (rune == 32) {
        if (allowSpaces) buf.write(' ');
      } else if (rune >= 33 && rune <= 126) {
        buf.writeCharCode(rune);
      }
    }
    return buf.toString();
  }

  @override
  String encryptChunk(String text, Alphabet alphabet) => _map(text);

  @override
  String decryptChunk(String text, Alphabet alphabet) => _map(text);
}

class TapCodeCipher extends CipherEngine {
  @override
  bool get isEncoding => true;

  @override
  Alphabet cipherSideAlphabet(Alphabet plainAlphabet) => const Alphabet(
        id: 'tap_out',
        nameKey: 'encodingOut',
        letters: '. ',
        category: AlphabetCategory.mixed,
      );

  @override
  String buildCipherAlphabet(Alphabet alphabet) => '.';

  @override
  List<String>? cipherInsertTokens(Alphabet alphabet) => ['.', ' '];

  Map<String, String> _table(Alphabet alphabet) {
    final side = 5;
    final map = <String, String>{};
    final chars = alphabet.chars;
    for (var i = 0; i < chars.length && i < side * side; i++) {
      final r = i ~/ side + 1;
      final c = i % side + 1;
      map[chars[i]] = '${'.' * r} ${'.' * c}';
    }
    return map;
  }

  @override
  String encryptChunk(String text, Alphabet alphabet) {
    final table = _table(alphabet);
    final parts = <String>[];
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (char == ' ') {
        parts.add('/');
        continue;
      }
      final code = table[char.toLowerCase()];
      if (code != null) parts.add(code);
    }
    return parts.join('  ');
  }

  @override
  String decryptChunk(String text, Alphabet alphabet) {
    final reverse = <String, String>{
      for (final e in _table(alphabet).entries) e.value: e.key,
    };
    final words = text.split('/');
    final out = <String>[];
    for (final word in words) {
      final tokens = word.trim().split(RegExp(r'\s{2,}'));
      final buf = StringBuffer();
      for (final token in tokens) {
        final t = token.trim();
        if (t.isEmpty) continue;
        final letter = reverse[t];
        if (letter != null) buf.write(letter);
      }
      out.add(buf.toString());
    }
    return out.join(' ');
  }

  @override
  String encrypt(String text, Alphabet alphabet,
          {SpaceMode spaceMode = SpaceMode.keep}) =>
      encryptChunk(text, alphabet);

  @override
  String decrypt(String text, Alphabet alphabet,
          {SpaceMode spaceMode = SpaceMode.keep}) =>
      decryptChunk(text, alphabet);
}

class ScytaleCipher extends CipherEngine {
  final int diameter;

  ScytaleCipher({required this.diameter});

  int get _d => diameter < 2 ? 2 : diameter;

  @override
  String buildCipherAlphabet(Alphabet alphabet) => alphabet.lower;

  @override
  String encryptChunk(String text, Alphabet alphabet) {
    final filtered = filterInput(text, alphabet, allowSpaces: true);
    if (filtered.isEmpty) return '';
    final d = _d;
    final chars = filtered.runes.map(String.fromCharCode).toList();
    final rows = (chars.length / d).ceil();
    final buf = StringBuffer();
    for (var c = 0; c < d; c++) {
      for (var r = 0; r < rows; r++) {
        final i = r * d + c;
        if (i < chars.length) buf.write(chars[i]);
      }
    }
    return buf.toString();
  }

  @override
  String decryptChunk(String text, Alphabet alphabet) {
    final filtered = filterInput(text, alphabet, allowSpaces: true);
    if (filtered.isEmpty) return '';
    final d = _d;
    final chars = filtered.runes.map(String.fromCharCode).toList();
    final n = chars.length;
    final rows = (n / d).ceil();
    final grid = List.generate(rows, (_) => List.filled(d, ''));
    var offset = 0;
    final shortCols = d * rows - n;
    for (var c = 0; c < d; c++) {
      final h = c >= d - shortCols ? rows - 1 : rows;
      for (var r = 0; r < h; r++) {
        grid[r][c] = chars[offset++];
      }
    }
    final buf = StringBuffer();
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < d; c++) {
        if (grid[r][c].isNotEmpty) buf.write(grid[r][c]);
      }
    }
    return buf.toString();
  }
}

/// Custom monoalphabetic substitution from a saved cipher alphabet string.
class CustomSubstitutionCipher extends CipherEngine {
  final String cipherLetters;

  CustomSubstitutionCipher({required this.cipherLetters});

  @override
  String buildCipherAlphabet(Alphabet alphabet) {
    final used = <String>{};
    final result = StringBuffer();
    for (final rune in cipherLetters.toLowerCase().runes) {
      final c = String.fromCharCode(rune);
      if (!alphabet.containsChar(c)) continue;
      if (used.add(c)) result.write(c);
    }
    for (final c in alphabet.chars) {
      if (used.add(c)) result.write(c);
    }
    return result.toString();
  }
}

/// Playfair digraph cipher.
class PlayfairCipher extends CipherEngine {
  final String keyword;

  PlayfairCipher({required this.keyword});

  @override
  String buildCipherAlphabet(Alphabet alphabet) {
    final used = <String>{};
    final result = StringBuffer();
    for (final rune in keyword.toLowerCase().runes) {
      final c = String.fromCharCode(rune);
      if (!alphabet.containsChar(c)) continue;
      if (used.add(c)) result.write(c);
    }
    for (final c in alphabet.chars) {
      if (used.add(c)) result.write(c);
    }
    return result.toString();
  }

  int _side(int n) {
    var s = 1;
    while ((s + 1) * (s + 1) <= n) {
      s++;
    }
    return s < 2 ? 2 : s;
  }

  List<String> _grid(Alphabet alphabet) {
    final letters = buildCipherAlphabet(alphabet)
        .runes
        .map(String.fromCharCode)
        .toList();
    final side = _side(letters.length);
    return letters.take(side * side).toList();
  }

  (int, int) _pos(List<String> grid, int side, String ch) {
    final i = grid.indexOf(ch);
    if (i < 0) return (-1, -1);
    return (i ~/ side, i % side);
  }

  String _prep(String text, Alphabet alphabet, List<String> grid) {
    final raw = filterInput(text, alphabet, allowSpaces: false).toLowerCase();
    if (raw.isEmpty) return '';
    final filler = alphabet.chars.firstWhere(
      (c) => c != raw[0] && grid.contains(c),
      orElse: () => alphabet.chars.first,
    );
    final out = StringBuffer();
    var i = 0;
    final chars = raw.runes.map(String.fromCharCode).toList();
    while (i < chars.length) {
      final a = chars[i];
      if (!grid.contains(a)) {
        i++;
        continue;
      }
      String b;
      if (i + 1 >= chars.length) {
        b = filler;
        i++;
      } else {
        b = chars[i + 1];
        if (!grid.contains(b) || a == b) {
          b = filler;
          i++;
        } else {
          i += 2;
        }
      }
      out.write(a);
      out.write(b);
    }
    return out.toString();
  }

  String _transform(String text, Alphabet alphabet, {required bool encrypt}) {
    final grid = _grid(alphabet);
    final side = _side(grid.length);
    // Pad grid conceptually to side*side with last letters repeating unused — only use existing.
    final prepared = _prep(text, alphabet, grid);
    if (prepared.isEmpty) return '';
    final dir = encrypt ? 1 : -1;
    final buf = StringBuffer();
    for (var i = 0; i + 1 < prepared.length; i += 2) {
      final a = prepared[i];
      final b = prepared[i + 1];
      final (r1, c1) = _pos(grid, side, a);
      final (r2, c2) = _pos(grid, side, b);
      if (r1 < 0 || r2 < 0) continue;
      if (r1 == r2) {
        buf.write(grid[r1 * side + mod(c1 + dir, side)]);
        buf.write(grid[r2 * side + mod(c2 + dir, side)]);
      } else if (c1 == c2) {
        buf.write(grid[mod(r1 + dir, side) * side + c1]);
        buf.write(grid[mod(r2 + dir, side) * side + c2]);
      } else {
        buf.write(grid[r1 * side + c2]);
        buf.write(grid[r2 * side + c1]);
      }
    }
    return buf.toString();
  }

  @override
  String encryptChunk(String text, Alphabet alphabet) =>
      _transform(text, alphabet, encrypt: true);

  @override
  String decryptChunk(String text, Alphabet alphabet) =>
      _transform(text, alphabet, encrypt: false);
}
