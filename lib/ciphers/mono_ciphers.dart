import '../models/alphabet.dart';
import 'cipher_engine.dart';

class MirrorCipher extends CipherEngine {
  @override
  String buildCipherAlphabet(Alphabet alphabet) {
    return alphabet.chars.reversed.join();
  }
}

class CaesarCipher extends CipherEngine {
  final int shift;

  CaesarCipher({required this.shift});

  @override
  String buildCipherAlphabet(Alphabet alphabet) =>
      shiftAlphabet(alphabet, shift);
}

class RotHalfCipher extends CipherEngine {
  @override
  String buildCipherAlphabet(Alphabet alphabet) {
    return shiftAlphabet(alphabet, alphabet.length ~/ 2);
  }
}

class KeywordCaesarCipher extends CipherEngine {
  final String keyword;

  KeywordCaesarCipher({required this.keyword});

  @override
  String buildCipherAlphabet(Alphabet alphabet) {
    final used = <String>{};
    final result = StringBuffer();

    for (final rune in keyword.toLowerCase().runes) {
      final char = String.fromCharCode(rune);
      if (!alphabet.containsChar(char)) continue;
      if (used.add(char)) result.write(char);
    }

    for (final char in alphabet.chars) {
      if (used.add(char)) result.write(char);
    }
    return result.toString();
  }
}

class AffineCipher extends CipherEngine {
  final int a;
  final int b;

  AffineCipher({required this.a, required this.b});

  int get _safeA {
    // Fallback to 1 if not coprime — checked at UI, still guard here.
    return a == 0 ? 1 : a;
  }

  @override
  String buildCipherAlphabet(Alphabet alphabet) {
    final n = alphabet.length;
    if (n == 0) return '';
    var mul = _safeA;
    if (gcd(mod(mul, n), n) != 1) mul = 1;
    final result = StringBuffer();
    for (var i = 0; i < n; i++) {
      result.write(alphabet.charAt(mod(mul * i + b, n)));
    }
    return result.toString();
  }
}

class OddEvenCipher extends CipherEngine {
  @override
  String buildCipherAlphabet(Alphabet alphabet) {
    final chars = alphabet.chars;
    final odds = <String>[];
    final evens = <String>[];
    for (var i = 0; i < chars.length; i++) {
      if (i.isEven) {
        evens.add(chars[i]);
      } else {
        odds.add(chars[i]);
      }
    }
    return [...evens, ...odds].join();
  }
}

class KeyboardLayoutCipher extends CipherEngine {
  final String layout;

  KeyboardLayoutCipher({required this.layout});

  @override
  String buildCipherAlphabet(Alphabet alphabet) {
    final used = <String>{};
    final result = StringBuffer();
    for (final rune in layout.toLowerCase().runes) {
      final char = String.fromCharCode(rune);
      if (!alphabet.containsChar(char)) continue;
      if (used.add(char)) result.write(char);
    }
    for (final char in alphabet.chars) {
      if (used.add(char)) result.write(char);
    }
    return result.toString();
  }
}

const qwertyLayout = 'qwertyuiopasdfghjklzxcvbnm';
const ycukenLayout = 'йцукенгшщзхъфывапролджэячсмитьбюё';
