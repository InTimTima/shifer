enum AlphabetCategory {
  letters,
  digits,
  mixed,
  custom,
}

class Alphabet {
  final String id;
  final String nameKey;
  final String letters;
  final AlphabetCategory category;
  final bool isCustom;

  const Alphabet({
    required this.id,
    required this.nameKey,
    required this.letters,
    this.category = AlphabetCategory.letters,
    this.isCustom = false,
  });

  /// Canonical character list. Case-folded when that does not create duplicates.
  List<String> get chars {
    final raw = letters.runes.map((r) => String.fromCharCode(r)).toList();
    final folded = raw.map((c) => c.toLowerCase()).toList();
    if (folded.toSet().length == folded.length) {
      return folded;
    }
    return raw;
  }

  String get lower => chars.join();

  int get length => chars.length;

  bool get isCaseSensitive {
    final raw = letters.runes.map((r) => String.fromCharCode(r)).toList();
    final folded = raw.map((c) => c.toLowerCase()).toList();
    return folded.toSet().length != folded.length;
  }

  bool containsChar(String char) {
    if (char.isEmpty) return false;
    if (chars.contains(char)) return true;
    if (isCaseSensitive) return false;
    return chars.contains(char.toLowerCase());
  }

  int indexOfChar(String char) {
    final list = chars;
    if (list.contains(char)) return list.indexOf(char);
    if (!isCaseSensitive) {
      final target = char.toLowerCase();
      for (var i = 0; i < list.length; i++) {
        if (list[i] == target) return i;
      }
    }
    return -1;
  }

  String charAt(int index) {
    final list = chars;
    final i = ((index % list.length) + list.length) % list.length;
    return list[i];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameKey': nameKey,
        'letters': letters,
        'category': category.name,
        'isCustom': isCustom,
      };

  factory Alphabet.fromJson(Map<String, dynamic> json) => Alphabet(
        id: json['id'] as String,
        nameKey: json['nameKey'] as String,
        letters: json['letters'] as String,
        category: AlphabetCategory.values.firstWhere(
          (c) => c.name == (json['category'] as String? ?? 'custom'),
          orElse: () => AlphabetCategory.custom,
        ),
        isCustom: json['isCustom'] as bool? ?? true,
      );

  Alphabet copyWith({
    String? id,
    String? nameKey,
    String? letters,
    AlphabetCategory? category,
    bool? isCustom,
  }) {
    return Alphabet(
      id: id ?? this.id,
      nameKey: nameKey ?? this.nameKey,
      letters: letters ?? this.letters,
      category: category ?? this.category,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}

class BuiltinAlphabets {
  static const russian = Alphabet(
    id: 'ru',
    nameKey: 'alphabetRussian',
    letters: 'абвгдеёжзийклмнопрстуфхцчшщъыьэюя',
  );

  static const ukrainian = Alphabet(
    id: 'uk',
    nameKey: 'alphabetUkrainian',
    letters: 'абвгґдеєжзиіїйклмнопрстуфхцчшщьюя',
  );

  static const english = Alphabet(
    id: 'en',
    nameKey: 'alphabetEnglish',
    letters: 'abcdefghijklmnopqrstuvwxyz',
  );

  static const german = Alphabet(
    id: 'de',
    nameKey: 'alphabetGerman',
    letters: 'abcdefghijklmnopqrstuvwxyzäöüß',
  );

  static const french = Alphabet(
    id: 'fr',
    nameKey: 'alphabetFrench',
    letters: 'abcdefghijklmnopqrstuvwxyzàâäæçéèêëïîôœùûüÿ',
  );

  static const spanish = Alphabet(
    id: 'es',
    nameKey: 'alphabetSpanish',
    letters: 'abcdefghijklmnñopqrstuvwxyz',
  );

  static const italian = Alphabet(
    id: 'it',
    nameKey: 'alphabetItalian',
    letters: 'abcdefghijklmnopqrstuvwxyz',
  );

  static const polish = Alphabet(
    id: 'pl',
    nameKey: 'alphabetPolish',
    letters: 'aąbcćdeęfghijklłmnńoóprsśtuwyzźż',
  );

  static const turkish = Alphabet(
    id: 'tr',
    nameKey: 'alphabetTurkish',
    letters: 'abcçdefgğhıijklmnoöprsştuüvyz',
  );

  static const portuguese = Alphabet(
    id: 'pt',
    nameKey: 'alphabetPortuguese',
    letters: 'abcdefghijklmnopqrstuvwxyzáàâãçéêíóôõú',
  );

  static const greek = Alphabet(
    id: 'el',
    nameKey: 'alphabetGreek',
    letters: 'αβγδεζηθικλμνξοπρστυφχψω',
  );

  static const dutch = Alphabet(
    id: 'nl',
    nameKey: 'alphabetDutch',
    letters: 'abcdefghijklmnopqrstuvwxyz',
  );

  static const czech = Alphabet(
    id: 'cs',
    nameKey: 'alphabetCzech',
    letters: 'aábcčdďeéěfghiíjklmnňoóprřsštťuúůvxyýzž',
  );

  static const swedish = Alphabet(
    id: 'sv',
    nameKey: 'alphabetSwedish',
    letters: 'abcdefghijklmnopqrstuvwxyzåäö',
  );

  static const digits09 = Alphabet(
    id: 'digits09',
    nameKey: 'alphabetDigits09',
    letters: '0123456789',
    category: AlphabetCategory.digits,
  );

  static const digits19 = Alphabet(
    id: 'digits19',
    nameKey: 'alphabetDigits19',
    letters: '123456789',
    category: AlphabetCategory.digits,
  );

  static const hex = Alphabet(
    id: 'hex',
    nameKey: 'alphabetHex',
    letters: '0123456789abcdef',
    category: AlphabetCategory.mixed,
  );

  static const alphanumeric = Alphabet(
    id: 'alnum',
    nameKey: 'alphabetAlphanumeric',
    letters: 'abcdefghijklmnopqrstuvwxyz0123456789',
    category: AlphabetCategory.mixed,
  );

  static const binary = Alphabet(
    id: 'binary',
    nameKey: 'alphabetBinary',
    letters: '01',
    category: AlphabetCategory.digits,
  );

  static const base64 = Alphabet(
    id: 'base64',
    nameKey: 'alphabetBase64',
    letters:
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/',
    category: AlphabetCategory.mixed,
  );

  static const List<Alphabet> all = [
    russian,
    ukrainian,
    english,
    german,
    french,
    spanish,
    italian,
    polish,
    turkish,
    portuguese,
    greek,
    dutch,
    czech,
    swedish,
    digits09,
    digits19,
    hex,
    alphanumeric,
    binary,
    base64,
  ];

  static Alphabet? byId(String id) {
    for (final a in all) {
      if (a.id == id) return a;
    }
    return null;
  }

  static List<Alphabet> byCategory(AlphabetCategory category) =>
      all.where((a) => a.category == category).toList();
}
