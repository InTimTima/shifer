import '../models/alphabet.dart';
import 'cipher_engine.dart';

class RailFenceCipher extends CipherEngine {
  final int rails;

  RailFenceCipher({required this.rails});

  int get _rails => rails < 2 ? 2 : rails;

  @override
  String buildCipherAlphabet(Alphabet alphabet) => alphabet.lower;

  @override
  String encryptChunk(String text, Alphabet alphabet) {
    final filtered = filterInput(text, alphabet, allowSpaces: true);
    if (filtered.isEmpty) return '';
    final r = _rails;
    if (r >= filtered.length) return filtered;

    final rows = List.generate(r, (_) => StringBuffer());
    var row = 0;
    var dir = 1;
    for (final rune in filtered.runes) {
      rows[row].write(String.fromCharCode(rune));
      row += dir;
      if (row == 0 || row == r - 1) dir = -dir;
    }
    return rows.map((b) => b.toString()).join();
  }

  @override
  String decryptChunk(String text, Alphabet alphabet) {
    final filtered = filterInput(text, alphabet, allowSpaces: true);
    if (filtered.isEmpty) return '';
    final r = _rails;
    final len = filtered.length;
    if (r >= len) return filtered;

    final pattern = List<int>.filled(len, 0);
    var row = 0;
    var dir = 1;
    for (var i = 0; i < len; i++) {
      pattern[i] = row;
      row += dir;
      if (row == 0 || row == r - 1) dir = -dir;
    }

    final counts = List<int>.filled(r, 0);
    for (final p in pattern) {
      counts[p]++;
    }

    final rows = <List<String>>[];
    var offset = 0;
    final chars = filtered.runes.map((e) => String.fromCharCode(e)).toList();
    for (var i = 0; i < r; i++) {
      rows.add(chars.sublist(offset, offset + counts[i]));
      offset += counts[i];
    }

    final pointers = List<int>.filled(r, 0);
    final buffer = StringBuffer();
    for (final p in pattern) {
      buffer.write(rows[p][pointers[p]]);
      pointers[p]++;
    }
    return buffer.toString();
  }
}

class ColumnarTranspositionCipher extends CipherEngine {
  final String keyword;

  ColumnarTranspositionCipher({required this.keyword});

  @override
  String buildCipherAlphabet(Alphabet alphabet) => alphabet.lower;

  List<int> _order(Alphabet alphabet) {
    final keyChars = <String>[];
    for (final rune in keyword.toLowerCase().runes) {
      final c = String.fromCharCode(rune);
      if (alphabet.containsChar(c)) keyChars.add(c);
    }
    if (keyChars.isEmpty) return [0];

    final indexed = [
      for (var i = 0; i < keyChars.length; i++) (i, keyChars[i]),
    ];
    indexed.sort((a, b) {
      final cmp = alphabet.indexOfChar(a.$2).compareTo(alphabet.indexOfChar(b.$2));
      if (cmp != 0) return cmp;
      return a.$1.compareTo(b.$1);
    });
    return indexed.map((e) => e.$1).toList();
  }

  @override
  String encryptChunk(String text, Alphabet alphabet) {
    final filtered = filterInput(text, alphabet, allowSpaces: true);
    if (filtered.isEmpty) return '';
    final order = _order(alphabet);
    final cols = order.length;
    if (cols <= 1) return filtered;

    final chars = filtered.runes.map((e) => String.fromCharCode(e)).toList();
    final rows = (chars.length / cols).ceil();
    final grid = List.generate(rows, (_) => List.filled(cols, ''));
    for (var i = 0; i < chars.length; i++) {
      grid[i ~/ cols][i % cols] = chars[i];
    }

    final buffer = StringBuffer();
    for (final col in order) {
      for (var r = 0; r < rows; r++) {
        final ch = grid[r][col];
        if (ch.isNotEmpty) buffer.write(ch);
      }
    }
    return buffer.toString();
  }

  @override
  String decryptChunk(String text, Alphabet alphabet) {
    final filtered = filterInput(text, alphabet, allowSpaces: true);
    if (filtered.isEmpty) return '';
    final order = _order(alphabet);
    final cols = order.length;
    if (cols <= 1) return filtered;

    final chars = filtered.runes.map((e) => String.fromCharCode(e)).toList();
    final len = chars.length;
    final rows = (len / cols).ceil();
    final shortCols = cols * rows - len;
    final colHeights = List<int>.filled(cols, rows);
    for (var c = cols - shortCols; c < cols; c++) {
      colHeights[c] = rows - 1;
    }

    final grid = List.generate(rows, (_) => List.filled(cols, ''));
    var offset = 0;
    for (final col in order) {
      final h = colHeights[col];
      for (var r = 0; r < h; r++) {
        grid[r][col] = chars[offset++];
      }
    }

    final buffer = StringBuffer();
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if (grid[r][c].isNotEmpty) buffer.write(grid[r][c]);
      }
    }
    return buffer.toString();
  }
}
