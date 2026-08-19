import '../models/alphabet.dart';
import 'cipher_engine.dart';

abstract class PolyalphabeticCipher extends CipherEngine {
  @override
  String buildCipherAlphabet(Alphabet alphabet) {
    // Preview: shift by first key character when available.
    final key = previewShift(alphabet);
    return shiftAlphabet(alphabet, key);
  }

  int previewShift(Alphabet alphabet);

  List<int> keyStream(String text, Alphabet alphabet);

  @override
  String encryptChunk(String text, Alphabet alphabet) {
    final n = alphabet.length;
    if (n == 0) return '';
    final stream = keyStream(text, alphabet);
    final buffer = StringBuffer();
    var ki = 0;
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (char == ' ') {
        buffer.write(' ');
        continue;
      }
      final idx = alphabet.indexOfChar(char);
      if (idx < 0) continue;
      final shift = stream[ki % stream.length];
      ki++;
      buffer.write(
        preserveCase(char, alphabet.charAt(encryptIndex(idx, shift, n))),
      );
    }
    return buffer.toString();
  }

  @override
  String decryptChunk(String text, Alphabet alphabet) {
    final n = alphabet.length;
    if (n == 0) return '';
    final stream = keyStream(text, alphabet);
    final buffer = StringBuffer();
    var ki = 0;
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (char == ' ') {
        buffer.write(' ');
        continue;
      }
      final idx = alphabet.indexOfChar(char);
      if (idx < 0) continue;
      final shift = stream[ki % stream.length];
      ki++;
      buffer.write(
        preserveCase(char, alphabet.charAt(decryptIndex(idx, shift, n))),
      );
    }
    return buffer.toString();
  }

  int encryptIndex(int idx, int shift, int n) => mod(idx + shift, n);
  int decryptIndex(int idx, int shift, int n) => mod(idx - shift, n);
}

class VigenereCipher extends PolyalphabeticCipher {
  final String keyword;

  VigenereCipher({required this.keyword});

  @override
  int previewShift(Alphabet alphabet) {
    for (final rune in keyword.toLowerCase().runes) {
      final i = alphabet.indexOfChar(String.fromCharCode(rune));
      if (i >= 0) return i;
    }
    return 0;
  }

  @override
  List<int> keyStream(String text, Alphabet alphabet) {
    final shifts = <int>[];
    for (final rune in keyword.toLowerCase().runes) {
      final i = alphabet.indexOfChar(String.fromCharCode(rune));
      if (i >= 0) shifts.add(i);
    }
    return shifts.isEmpty ? [0] : shifts;
  }
}

class BeaufortCipher extends PolyalphabeticCipher {
  final String keyword;

  BeaufortCipher({required this.keyword});

  @override
  int previewShift(Alphabet alphabet) {
    for (final rune in keyword.toLowerCase().runes) {
      final i = alphabet.indexOfChar(String.fromCharCode(rune));
      if (i >= 0) return i;
    }
    return 0;
  }

  @override
  List<int> keyStream(String text, Alphabet alphabet) {
    final shifts = <int>[];
    for (final rune in keyword.toLowerCase().runes) {
      final i = alphabet.indexOfChar(String.fromCharCode(rune));
      if (i >= 0) shifts.add(i);
    }
    return shifts.isEmpty ? [0] : shifts;
  }

  // Beaufort: C = (K - P) mod n ; decrypt same as encrypt
  @override
  int encryptIndex(int idx, int shift, int n) => mod(shift - idx, n);

  @override
  int decryptIndex(int idx, int shift, int n) => mod(shift - idx, n);
}

class VariantBeaufortCipher extends PolyalphabeticCipher {
  final String keyword;

  VariantBeaufortCipher({required this.keyword});

  @override
  int previewShift(Alphabet alphabet) {
    for (final rune in keyword.toLowerCase().runes) {
      final i = alphabet.indexOfChar(String.fromCharCode(rune));
      if (i >= 0) return i;
    }
    return 0;
  }

  @override
  List<int> keyStream(String text, Alphabet alphabet) {
    final shifts = <int>[];
    for (final rune in keyword.toLowerCase().runes) {
      final i = alphabet.indexOfChar(String.fromCharCode(rune));
      if (i >= 0) shifts.add(i);
    }
    return shifts.isEmpty ? [0] : shifts;
  }

  // Variant Beaufort: C = (P - K) mod n
  @override
  int encryptIndex(int idx, int shift, int n) => mod(idx - shift, n);

  @override
  int decryptIndex(int idx, int shift, int n) => mod(idx + shift, n);
}

class AutokeyCipher extends CipherEngine {
  final String keyword;

  AutokeyCipher({required this.keyword});

  @override
  String buildCipherAlphabet(Alphabet alphabet) {
    for (final rune in keyword.toLowerCase().runes) {
      final i = alphabet.indexOfChar(String.fromCharCode(rune));
      if (i >= 0) return shiftAlphabet(alphabet, i);
    }
    return alphabet.lower;
  }

  List<int> _primer(Alphabet alphabet) {
    final shifts = <int>[];
    for (final rune in keyword.toLowerCase().runes) {
      final i = alphabet.indexOfChar(String.fromCharCode(rune));
      if (i >= 0) shifts.add(i);
    }
    return shifts;
  }

  @override
  String encryptChunk(String text, Alphabet alphabet) {
    final n = alphabet.length;
    if (n == 0) return '';
    final primer = _primer(alphabet);
    final buffer = StringBuffer();
    final plainIdx = <int>[];

    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (char == ' ') {
        buffer.write(' ');
        continue;
      }
      final idx = alphabet.indexOfChar(char);
      if (idx < 0) continue;
      final shift = plainIdx.length < primer.length
          ? (primer.isEmpty ? 0 : primer[plainIdx.length])
          : plainIdx[plainIdx.length - primer.length];
      final effectiveShift = primer.isEmpty
          ? (plainIdx.isEmpty ? 0 : plainIdx.last)
          : shift;
      final out = mod(idx + effectiveShift, n);
      plainIdx.add(idx);
      buffer.write(preserveCase(char, alphabet.charAt(out)));
    }
    return buffer.toString();
  }

  @override
  String decryptChunk(String text, Alphabet alphabet) {
    final n = alphabet.length;
    if (n == 0) return '';
    final primer = _primer(alphabet);
    final buffer = StringBuffer();
    final plainIdx = <int>[];

    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (char == ' ') {
        buffer.write(' ');
        continue;
      }
      final idx = alphabet.indexOfChar(char);
      if (idx < 0) continue;
      final effectiveShift = primer.isEmpty
          ? (plainIdx.isEmpty ? 0 : plainIdx.last)
          : (plainIdx.length < primer.length
              ? primer[plainIdx.length]
              : plainIdx[plainIdx.length - primer.length]);
      final out = mod(idx - effectiveShift, n);
      plainIdx.add(out);
      buffer.write(preserveCase(char, alphabet.charAt(out)));
    }
    return buffer.toString();
  }
}

class GronsfeldCipher extends PolyalphabeticCipher {
  final String digitKey;

  GronsfeldCipher({required this.digitKey});

  @override
  int previewShift(Alphabet alphabet) {
    for (final rune in digitKey.runes) {
      final d = int.tryParse(String.fromCharCode(rune));
      if (d != null) return d;
    }
    return 0;
  }

  @override
  List<int> keyStream(String text, Alphabet alphabet) {
    final shifts = <int>[];
    for (final rune in digitKey.runes) {
      final d = int.tryParse(String.fromCharCode(rune));
      if (d != null) shifts.add(d);
    }
    return shifts.isEmpty ? [0] : shifts;
  }
}

class TrithemiusCipher extends PolyalphabeticCipher {
  @override
  int previewShift(Alphabet alphabet) => 0;

  @override
  List<int> keyStream(String text, Alphabet alphabet) {
    var len = 0;
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (char != ' ' && alphabet.containsChar(char)) len++;
    }
    if (len == 0) return [0];
    return [for (var i = 0; i < len; i++) i];
  }

  @override
  String buildCipherAlphabet(Alphabet alphabet) =>
      shiftAlphabet(alphabet, 1);
}

class PortaCipher extends CipherEngine {
  final String keyword;

  PortaCipher({required this.keyword});

  @override
  String buildCipherAlphabet(Alphabet alphabet) {
    // Porta pairs first/second half; preview with first key letter.
    final n = alphabet.length;
    if (n == 0 || n.isOdd) return alphabet.lower;
    final half = n ~/ 2;
    var keyIdx = 0;
    for (final rune in keyword.toLowerCase().runes) {
      final i = alphabet.indexOfChar(String.fromCharCode(rune));
      if (i >= 0) {
        keyIdx = i;
        break;
      }
    }
    final row = keyIdx ~/ 2;
    final result = StringBuffer();
    for (var i = 0; i < n; i++) {
      if (i < half) {
        result.write(alphabet.charAt(half + mod(i - row, half)));
      } else {
        result.write(alphabet.charAt(mod(i - half + row, half)));
      }
    }
    return result.toString();
  }

  int _rowForKeyChar(Alphabet alphabet, String keyChar) {
    final i = alphabet.indexOfChar(keyChar);
    if (i < 0) return 0;
    return i ~/ 2;
  }

  List<int> _rows(String text, Alphabet alphabet) {
    final rows = <int>[];
    for (final rune in keyword.toLowerCase().runes) {
      final char = String.fromCharCode(rune);
      if (alphabet.containsChar(char)) {
        rows.add(_rowForKeyChar(alphabet, char));
      }
    }
    return rows.isEmpty ? [0] : rows;
  }

  @override
  String encryptChunk(String text, Alphabet alphabet) {
    final n = alphabet.length;
    if (n == 0 || n.isOdd) {
      return filterInput(text, alphabet, allowSpaces: true);
    }
    final half = n ~/ 2;
    final rows = _rows(text, alphabet);
    final buffer = StringBuffer();
    var ki = 0;
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (char == ' ') {
        buffer.write(' ');
        continue;
      }
      final idx = alphabet.indexOfChar(char);
      if (idx < 0) continue;
      final row = rows[ki % rows.length];
      ki++;
      final out = idx < half
          ? half + mod(idx - row, half)
          : mod(idx - half + row, half);
      buffer.write(preserveCase(char, alphabet.charAt(out)));
    }
    return buffer.toString();
  }

  @override
  String decryptChunk(String text, Alphabet alphabet) {
    // Porta is reciprocal for standard construction.
    return encryptChunk(text, alphabet);
  }
}
