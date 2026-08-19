import '../models/alphabet.dart';
import '../models/space_mode.dart';
import 'cipher_engine.dart';

/// Shared helpers for codes where output alphabet differs from input.
abstract class EncodingCipher extends CipherEngine {
  @override
  bool get isEncoding => true;

  Map<String, String> tableFor(Alphabet alphabet);

  Map<String, String> reverseTable(Alphabet alphabet) {
    final forward = tableFor(alphabet);
    final reverse = <String, String>{};
    for (final entry in forward.entries) {
      reverse.putIfAbsent(entry.value, () => entry.key);
    }
    return reverse;
  }

  @override
  Alphabet cipherSideAlphabet(Alphabet plainAlphabet) {
    final symbols = <String>{};
    for (final code in tableFor(plainAlphabet).values) {
      for (final rune in code.runes) {
        symbols.add(String.fromCharCode(rune));
      }
    }
    // Separators commonly used when typing codes.
    symbols.addAll(['.', '-', '/', ' ']);
    return Alphabet(
      id: 'encoding_out_${plainAlphabet.id}',
      nameKey: 'encodingOut',
      letters: symbols.join(),
      category: AlphabetCategory.mixed,
    );
  }

  @override
  String buildCipherAlphabet(Alphabet alphabet) {
    final tokens = cipherInsertTokens(alphabet);
    final list = tokens ?? const <String>[];
    final singles = <String>{};
    for (final t in list) {
      for (final r in t.runes) {
        singles.add(String.fromCharCode(r));
      }
    }
    if (singles.isEmpty) return '.-/';
    return singles.join();
  }

  @override
  List<String>? cipherInsertTokens(Alphabet alphabet) {
    final values = tableFor(alphabet).values.toSet().toList()..sort();
    return values;
  }
}

class MorseCipher extends EncodingCipher {
  @override
  Map<String, String> tableFor(Alphabet alphabet) {
    if (alphabet.id == 'ru' || alphabet.id == 'uk') {
      return _morseRu;
    }
    return _morseEn;
  }

  @override
  List<String>? cipherInsertTokens(Alphabet alphabet) {
    // Keep codes in plaintext-alphabet order so the panel reads like a
    // normal alphabet (А→'.-', Б→'-...', …) instead of a sorted code list.
    final table = tableFor(alphabet);
    final list = <String>[];
    final seen = <String>{};
    for (final c in alphabet.chars) {
      final code = table[c];
      if (code != null && seen.add(code)) list.add(code);
    }
    return list;
  }

  @override
  String encryptChunk(String text, Alphabet alphabet) {
    final table = tableFor(alphabet);
    final words = <String>[];
    final current = <String>[];

    void flushWord() {
      if (current.isNotEmpty) {
        words.add(current.join(' '));
        current.clear();
      }
    }

    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (char == ' ') {
        flushWord();
        continue;
      }
      final code = table[char.toLowerCase()];
      if (code != null) current.add(code);
    }
    flushWord();
    return words.join(' / ');
  }

  @override
  String decryptChunk(String text, Alphabet alphabet) {
    final reverse = reverseTable(alphabet);
    final wordParts = text.split(RegExp(r'\s*/\s*'));
    final outWords = <String>[];
    for (final word in wordParts) {
      final letters = word.trim().split(RegExp(r'\s+'));
      final buffer = StringBuffer();
      for (final code in letters) {
        if (code.isEmpty) continue;
        final letter = reverse[code];
        if (letter != null) buffer.write(letter);
      }
      outWords.add(buffer.toString());
    }
    return outWords.join(' ');
  }

  @override
  String encrypt(
    String text,
    Alphabet alphabet, {
    SpaceMode spaceMode = SpaceMode.keep,
  }) {
    // Morse always treats plaintext spaces as word separators.
    return encryptChunk(text, alphabet);
  }

  @override
  String decrypt(
    String text,
    Alphabet alphabet, {
    SpaceMode spaceMode = SpaceMode.keep,
  }) {
    return decryptChunk(text, alphabet);
  }
}

class BrailleCipher extends EncodingCipher {
  @override
  Map<String, String> tableFor(Alphabet alphabet) {
    if (alphabet.id == 'ru' || alphabet.id == 'uk') return _brailleRu;
    return _brailleEn;
  }

  @override
  Alphabet cipherSideAlphabet(Alphabet plainAlphabet) {
    final cells = tableFor(plainAlphabet).values.toSet().join();
    return Alphabet(
      id: 'braille_out',
      nameKey: 'encodingOut',
      letters: '$cells ',
      category: AlphabetCategory.mixed,
    );
  }

  @override
  List<String> cipherInsertTokens(Alphabet alphabet) {
    return tableFor(alphabet).values.toSet().toList()..sort();
  }

  @override
  String encryptChunk(String text, Alphabet alphabet) {
    final table = tableFor(alphabet);
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (char == ' ') {
        buffer.write(' ');
        continue;
      }
      final cell = table[char.toLowerCase()];
      if (cell != null) buffer.write(cell);
    }
    return buffer.toString();
  }

  @override
  String decryptChunk(String text, Alphabet alphabet) {
    final reverse = reverseTable(alphabet);
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (char == ' ') {
        buffer.write(' ');
        continue;
      }
      final letter = reverse[char];
      if (letter != null) buffer.write(letter);
    }
    return buffer.toString();
  }
}

class A1Z26Cipher extends EncodingCipher {
  @override
  Map<String, String> tableFor(Alphabet alphabet) {
    final map = <String, String>{};
    final chars = alphabet.chars;
    for (var i = 0; i < chars.length; i++) {
      map[chars[i]] = '${i + 1}';
    }
    return map;
  }

  @override
  Alphabet cipherSideAlphabet(Alphabet plainAlphabet) {
    return const Alphabet(
      id: 'a1z26_out',
      nameKey: 'encodingOut',
      letters: '0123456789-',
      category: AlphabetCategory.digits,
    );
  }

  @override
  List<String> cipherInsertTokens(Alphabet alphabet) {
    return ['-'];
  }

  @override
  String buildCipherAlphabet(Alphabet alphabet) => '0123456789-';

  @override
  String encryptChunk(String text, Alphabet alphabet) {
    final table = tableFor(alphabet);
    final words = <String>[];
    final current = <String>[];

    void flush() {
      if (current.isNotEmpty) {
        words.add(current.join('-'));
        current.clear();
      }
    }

    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (char == ' ') {
        flush();
        continue;
      }
      final code = table[char.toLowerCase()] ?? table[char];
      if (code != null) current.add(code);
    }
    flush();
    return words.join(' ');
  }

  @override
  String decryptChunk(String text, Alphabet alphabet) {
    final reverse = reverseTable(alphabet);
    final words = text.trim().split(RegExp(r'\s+'));
    final out = <String>[];
    for (final word in words) {
      if (word.isEmpty) continue;
      final buffer = StringBuffer();
      for (final part in word.split('-')) {
        if (part.isEmpty) continue;
        final letter = reverse[part];
        if (letter != null) buffer.write(letter);
      }
      out.add(buffer.toString());
    }
    return out.join(' ');
  }

  @override
  String encrypt(
    String text,
    Alphabet alphabet, {
    SpaceMode spaceMode = SpaceMode.keep,
  }) =>
      encryptChunk(text, alphabet);

  @override
  String decrypt(
    String text,
    Alphabet alphabet, {
    SpaceMode spaceMode = SpaceMode.keep,
  }) =>
      decryptChunk(text, alphabet);
}

class NatoPhoneticCipher extends EncodingCipher {
  @override
  Map<String, String> tableFor(Alphabet alphabet) => _nato;

  @override
  bool get isEncoding => true;

  @override
  Alphabet cipherSideAlphabet(Alphabet plainAlphabet) {
    // Allow typing letters that form phonetic words + spaces.
    return const Alphabet(
      id: 'nato_out',
      nameKey: 'encodingOut',
      letters: 'abcdefghijklmnopqrstuvwxyz ',
      category: AlphabetCategory.letters,
    );
  }

  @override
  List<String> cipherInsertTokens(Alphabet alphabet) {
    return _nato.values.toList();
  }

  @override
  String buildCipherAlphabet(Alphabet alphabet) =>
      'abcdefghijklmnopqrstuvwxyz';

  @override
  String encryptChunk(String text, Alphabet alphabet) {
    final words = <String>[];
    final current = <String>[];

    void flush() {
      if (current.isNotEmpty) {
        words.add(current.join(' '));
        current.clear();
      }
    }

    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (char == ' ') {
        flush();
        continue;
      }
      final code = _nato[char.toLowerCase()];
      if (code != null) current.add(code);
    }
    flush();
    return words.join(' | ');
  }

  @override
  String decryptChunk(String text, Alphabet alphabet) {
    final reverse = <String, String>{
      for (final e in _nato.entries) e.value.toLowerCase(): e.key,
    };
    final groups = text.split(RegExp(r'\s*\|\s*'));
    final outWords = <String>[];
    for (final group in groups) {
      final buffer = StringBuffer();
      for (final token in group.trim().split(RegExp(r'\s+'))) {
        if (token.isEmpty) continue;
        final letter = reverse[token.toLowerCase()];
        if (letter != null) buffer.write(letter);
      }
      outWords.add(buffer.toString());
    }
    return outWords.join(' ');
  }

  @override
  String encrypt(
    String text,
    Alphabet alphabet, {
    SpaceMode spaceMode = SpaceMode.keep,
  }) =>
      encryptChunk(text, alphabet);

  @override
  String decrypt(
    String text,
    Alphabet alphabet, {
    SpaceMode spaceMode = SpaceMode.keep,
  }) =>
      decryptChunk(text, alphabet);
}

// International Morse (Latin).
const _morseEn = {
  'a': '.-',
  'b': '-...',
  'c': '-.-.',
  'd': '-..',
  'e': '.',
  'f': '..-.',
  'g': '--.',
  'h': '....',
  'i': '..',
  'j': '.---',
  'k': '-.-',
  'l': '.-..',
  'm': '--',
  'n': '-.',
  'o': '---',
  'p': '.--.',
  'q': '--.-',
  'r': '.-.',
  's': '...',
  't': '-',
  'u': '..-',
  'v': '...-',
  'w': '.--',
  'x': '-..-',
  'y': '-.--',
  'z': '--..',
  '0': '-----',
  '1': '.----',
  '2': '..---',
  '3': '...--',
  '4': '....-',
  '5': '.....',
  '6': '-....',
  '7': '--...',
  '8': '---..',
  '9': '----.',
};

// Russian Morse.
const _morseRu = {
  'а': '.-',
  'б': '-...',
  'в': '.--',
  'г': '--.',
  'д': '-..',
  'е': '.',
  'ё': '.',
  'ж': '...-',
  'з': '--..',
  'и': '..',
  'й': '.---',
  'к': '-.-',
  'л': '.-..',
  'м': '--',
  'н': '-.',
  'о': '---',
  'п': '.--.',
  'р': '.-.',
  'с': '...',
  'т': '-',
  'у': '..-',
  'ф': '..-.',
  'х': '....',
  'ц': '-.-.',
  'ч': '---.',
  'ш': '----',
  'щ': '--.-',
  'ъ': '--.--',
  'ы': '-.--',
  'ь': '-..-',
  'э': '..-..',
  'ю': '..--',
  'я': '.-.-',
  '0': '-----',
  '1': '.----',
  '2': '..---',
  '3': '...--',
  '4': '....-',
  '5': '.....',
  '6': '-....',
  '7': '--...',
  '8': '---..',
  '9': '----.',
};

// English grade-1 Braille (U+2801…).
const _brailleEn = {
  'a': '⠁',
  'b': '⠃',
  'c': '⠉',
  'd': '⠙',
  'e': '⠑',
  'f': '⠋',
  'g': '⠛',
  'h': '⠓',
  'i': '⠊',
  'j': '⠚',
  'k': '⠅',
  'l': '⠇',
  'm': '⠍',
  'n': '⠝',
  'o': '⠕',
  'p': '⠏',
  'q': '⠟',
  'r': '⠗',
  's': '⠎',
  't': '⠞',
  'u': '⠥',
  'v': '⠧',
  'w': '⠺',
  'x': '⠭',
  'y': '⠽',
  'z': '⠵',
};

// Russian Braille (common literary mapping).
const _brailleRu = {
  'а': '⠁',
  'б': '⠃',
  'в': '⠺',
  'г': '⠛',
  'д': '⠙',
  'е': '⠑',
  'ё': '⠡',
  'ж': '⠚',
  'з': '⠵',
  'и': '⠊',
  'й': '⠯',
  'к': '⠅',
  'л': '⠇',
  'м': '⠍',
  'н': '⠝',
  'о': '⠕',
  'п': '⠏',
  'р': '⠗',
  'с': '⠎',
  'т': '⠞',
  'у': '⠥',
  'ф': '⠋',
  'х': '⠓',
  'ц': '⠉',
  'ч': '⠟',
  'ш': '⠱',
  'щ': '⠭',
  'ъ': '⠷',
  'ы': '⠮',
  'ь': '⠾',
  'э': '⠪',
  'ю': '⠳',
  'я': '⠹',
};

const _nato = {
  'a': 'Alpha',
  'b': 'Bravo',
  'c': 'Charlie',
  'd': 'Delta',
  'e': 'Echo',
  'f': 'Foxtrot',
  'g': 'Golf',
  'h': 'Hotel',
  'i': 'India',
  'j': 'Juliet',
  'k': 'Kilo',
  'l': 'Lima',
  'm': 'Mike',
  'n': 'November',
  'o': 'Oscar',
  'p': 'Papa',
  'q': 'Quebec',
  'r': 'Romeo',
  's': 'Sierra',
  't': 'Tango',
  'u': 'Uniform',
  'v': 'Victor',
  'w': 'Whiskey',
  'x': 'X-ray',
  'y': 'Yankee',
  'z': 'Zulu',
};
