import 'cipher_texts.dart';

class AppStrings {
  final String localeCode;

  const AppStrings(this.localeCode);

  bool get isRu => localeCode == 'ru';

  Map<String, String> get _m => isRu ? _ru : _en;

  String t(String key) => CipherTexts.map(isRu)[key] ?? _m[key] ?? key;

  String get appName => 'Shifer';
  String get appTagline => t('appTagline');
  String get chooseCipher => t('chooseCipher');
  String get appLanguage => t('appLanguage');
  String get themeToggle => t('themeToggle');
  String get open => t('open');
  String get example => t('example');
  String get exampleWord => t('exampleWord');
  String get back => t('back');
  String get help => t('help');
  String get alphabetLabel => t('alphabetLabel');
  String get originalAlphabet => t('originalAlphabet');
  String get modifiedAlphabet => t('modifiedAlphabet');
  String get enterText => t('enterText');
  String get modifiedText => t('modifiedText');
  String get caesarKey => t('caesarKey');
  String get keyword => t('keyword');
  String get digitKey => t('digitKey');
  String get affineA => t('affineA');
  String get affineB => t('affineB');
  String get rails => t('rails');
  String get customAlphabet => t('customAlphabet');
  String get newAlphabetTitle => t('newAlphabetTitle');
  String get alphabetName => t('alphabetName');
  String get alphabetLetters => t('alphabetLetters');
  String get save => t('save');
  String get cancel => t('cancel');
  String get delete => t('delete');
  String get settings => t('settings');
  String get close => t('close');
  String get alphabetErrorEmpty => t('alphabetErrorEmpty');
  String get alphabetErrorDuplicate => t('alphabetErrorDuplicate');
  String get searchCipher => t('searchCipher');
  String get allCategories => t('allCategories');
  String get noCiphersFound => t('noCiphersFound');
  String get categoryClassic => t('categoryClassic');
  String get categoryMono => t('categoryMono');
  String get categoryPoly => t('categoryPoly');
  String get categoryTransposition => t('categoryTransposition');
  String get categoryEncoding => t('categoryEncoding');
  String get alphabetCatLetters => t('alphabetCatLetters');
  String get alphabetCatDigits => t('alphabetCatDigits');
  String get alphabetCatMixed => t('alphabetCatMixed');
  String get alphabetCatCustom => t('alphabetCatCustom');
  String get affineNotCoprime => t('affineNotCoprime');
  String get spaceModeLabel => t('spaceModeLabel');
  String get spaceKeep => t('spaceKeep');
  String get spacePerWord => t('spacePerWord');
  String get spaceUnsupported => t('spaceUnsupported');
  String get spaceKeepHint => t('spaceKeepHint');
  String get spacePerWordHint => t('spacePerWordHint');
  String get clickAlphabetHint => t('clickAlphabetHint');
  String get navCiphers => t('navCiphers');
  String get navDetector => t('navDetector');
  String get navStudio => t('navStudio');
  String get detectorTitle => t('detectorTitle');
  String get detectorSubtitle => t('detectorSubtitle');
  String get detectorHint => t('detectorHint');
  String get detectorAnalyze => t('detectorAnalyze');
  String get detectorNote => t('detectorNote');
  String get detectorEmpty => t('detectorEmpty');
  String get customStudioTitle => t('customStudioTitle');
  String get customStudioSubtitle => t('customStudioSubtitle');
  String get customCipherName => t('customCipherName');
  String get customCipherKeyword => t('customCipherKeyword');
  String get customCipherKeywordHelp => t('customCipherKeywordHelp');
  String get customCipherPreview => t('customCipherPreview');
  String get customCipherList => t('customCipherList');
  String get customCipherEmpty => t('customCipherEmpty');
  String get customCipherError => t('customCipherError');
  String get customCipherSaved => t('customCipherSaved');
  String get customCipherSavedDesc => t('customCipherSavedDesc');
  String get diameter => t('diameter');
  String get navMixer => t('navMixer');
  String get mixerTitle => t('mixerTitle');
  String get mixerSubtitle => t('mixerSubtitle');
  String get mixerBaseAlphabet => t('mixerBaseAlphabet');
  String get mixerAddHint => t('mixerAddHint');
  String get mixerCannotAdd => t('mixerCannotAdd');
  String get mixerEmpty => t('mixerEmpty');
  String get mixerClear => t('mixerClear');
  String get mixerInput => t('mixerInput');
  String get mixerOutput => t('mixerOutput');
  String get mixerAlphabetIn => t('mixerAlphabetIn');
  String get mixerAlphabetOut => t('mixerAlphabetOut');
  String get constructorRule => t('constructorRule');
  String get constructorSteps => t('constructorSteps');
  String get constructorAddStep => t('constructorAddStep');
  String get constructorNoSteps => t('constructorNoSteps');
  String get constructorNoParams => t('constructorNoParams');
  String get constructorExample => t('constructorExample');
  String get constructorMoveUp => t('constructorMoveUp');
  String get constructorMoveDown => t('constructorMoveDown');
  String get ruleShift => t('ruleShift');
  String get ruleMirror => t('ruleMirror');
  String get ruleKeyword => t('ruleKeyword');
  String get ruleCustom => t('ruleCustom');
  String get ruleAffine => t('ruleAffine');
  String get ruleRotHalf => t('ruleRotHalf');
  String get ruleOddEven => t('ruleOddEven');
  String get shiftAmount => t('shiftAmount');
  String get customLettersLabel => t('customLettersLabel');
  String get customLettersHelp => t('customLettersHelp');
  String get customLengthError => t('customLengthError');

  static const _ru = {
    'appTagline':
        'Простой шифратор и дешифратор с классическими и современными шифрами',
    'chooseCipher': 'Выберите шифр',
    'appLanguage': 'Язык приложения',
    'themeToggle': 'Переключить тему',
    'open': 'Открыть',
    'example': 'Пример',
    'back': 'Назад',
    'help': 'Помощь',
    'alphabetLabel': 'Алфавит для шифровки',
    'originalAlphabet': 'Оригинальный алфавит',
    'modifiedAlphabet': 'Изменённый алфавит',
    'enterText': 'Введите текст',
    'modifiedText': 'Изменённый текст',
    'caesarKey': 'Ключ (сдвиг)',
    'keyword': 'Ключевое слово',
    'digitKey': 'Цифровой ключ',
    'affineA': 'Коэффициент a',
    'affineB': 'Сдвиг b',
    'rails': 'Число рельсов',
    'customAlphabet': 'Свой алфавит…',
    'newAlphabetTitle': 'Новый алфавит',
    'alphabetName': 'Название',
    'alphabetLetters': 'Символы по порядку',
    'save': 'Сохранить',
    'cancel': 'Отмена',
    'delete': 'Удалить',
    'settings': 'Настройки',
    'close': 'Закрыть',
    'alphabetErrorEmpty': 'Введите название и символы',
    'alphabetErrorDuplicate':
        'В алфавите не должно быть повторяющихся символов',
    'searchCipher': 'Поиск шифра…',
    'allCategories': 'Все',
    'noCiphersFound': 'Шифры не найдены',
    'categoryClassic': 'Классические',
    'categoryMono': 'Подстановочные',
    'categoryPoly': 'Полиалфавитные',
    'categoryTransposition': 'Перестановочные',
    'alphabetCatLetters': 'Буквенные',
    'alphabetCatDigits': 'Цифровые',
    'alphabetCatMixed': 'Смешанные',
    'alphabetCatCustom': 'Свои',
    'affineNotCoprime': 'a должно быть взаимно простым с длиной алфавита',
    'alphabetRussian': 'Русский',
    'alphabetUkrainian': 'Украинский',
    'alphabetEnglish': 'Английский',
    'alphabetGerman': 'Немецкий',
    'alphabetFrench': 'Французский',
    'alphabetSpanish': 'Испанский',
    'alphabetItalian': 'Итальянский',
    'alphabetPolish': 'Польский',
    'alphabetTurkish': 'Турецкий',
    'alphabetPortuguese': 'Португальский',
    'alphabetGreek': 'Греческий',
    'alphabetDutch': 'Голландский',
    'alphabetCzech': 'Чешский',
    'alphabetSwedish': 'Шведский',
    'alphabetDigits09': 'Цифры 0–9',
    'alphabetDigits19': 'Цифры 1–9',
    'alphabetHex': 'Шестнадцатеричный',
    'alphabetAlphanumeric': 'Латиница + цифры',
    'alphabetBinary': 'Двоичный (0/1)',
    'alphabetBase64': 'Base64',
    'cipherMirror': 'Зеркальный (Атбаш)',
    'cipherMirrorDesc':
        'Алфавит разворачивается задом наперёд: первая буква меняется с последней.',
    'cipherMirrorHelp':
        'Зеркальный шифр (Атбаш) подставляет букву с противоположного конца алфавита.\n\nДополнительные ключи не нужны.',
    'cipherCaesar': 'Шифр Цезаря',
    'cipherCaesarDesc':
        'Каждая буква сдвигается на фиксированное число позиций по алфавиту.',
    'cipherCaesarHelp':
        'Укажите ключ-сдвиг. Вводите текст сверху для шифрования или снизу для дешифрования.',
    'cipherRotHalf': 'ROT (половина алфавита)',
    'cipherRotHalfDesc':
        'Фиксированный сдвиг на половину длины алфавита (для английского это ROT13).',
    'cipherRotHalfHelp':
        'Работает только с алфавитами чётной длины. Шифрование и дешифрование совпадают.',
    'cipherKeywordCaesar': 'Цезарь с ключевым словом',
    'cipherKeywordCaesarDesc':
        'Сначала идут уникальные буквы ключа, затем остальные буквы алфавита.',
    'cipherKeywordCaesarHelp':
        'Введите ключевое слово из букв выбранного алфавита.',
    'cipherAffine': 'Аффинный шифр',
    'cipherAffineDesc':
        'Подстановка по формуле (a·x + b) mod n. Коэффициент a должен быть взаимно простым с n.',
    'cipherAffineHelp':
        'Задайте a и b. Если a не взаимно просто с длиной алфавита, шифр станет необратимым — приложение подстрахует.',
    'cipherOddEven': 'Чёт-нечет',
    'cipherOddEvenDesc':
        'Сначала буквы с чётных позиций алфавита, затем с нечётных.',
    'cipherOddEvenHelp': 'Ключ не нужен. Простая перестройка порядка алфавита.',
    'cipherQwerty': 'QWERTY',
    'cipherQwertyDesc':
        'Алфавит перестраивается в порядке клавиш QWERTY.',
    'cipherQwertyHelp': 'Только для латинских алфавитов (английский и близкие).',
    'cipherYcuken': 'ЙЦУКЕН',
    'cipherYcukenDesc':
        'Алфавит перестраивается в порядке русской раскладки ЙЦУКЕН.',
    'cipherYcukenHelp': 'Только для русского алфавита.',
    'cipherVigenere': 'Вижене́р',
    'cipherVigenereDesc':
        'Полиалфавитный шифр: сдвиг меняется по буквам ключевого слова.',
    'cipherVigenereHelp':
        'Введите ключевое слово. Предпросмотр алфавита показывает сдвиг по первой букве ключа.',
    'cipherBeaufort': 'Бофор',
    'cipherBeaufortDesc':
        'Вариант Виженера: C = (K − P) mod n. Шифрование и дешифрование совпадают.',
    'cipherBeaufortHelp': 'Нужно ключевое слово из символов алфавита.',
    'cipherVariantBeaufort': 'Вариант Бофора',
    'cipherVariantBeaufortDesc':
        'C = (P − K) mod n — ещё одна классическая вариация Виженера.',
    'cipherVariantBeaufortHelp': 'Нужно ключевое слово.',
    'cipherAutokey': 'Автоключ',
    'cipherAutokeyDesc':
        'Виженер, где после ключа-праймера дальше идёт сам открытый текст.',
    'cipherAutokeyHelp': 'Введите праймер (начальный ключ).',
    'cipherGronsfeld': 'Гронсфельд',
    'cipherGronsfeldDesc':
        'Как Виженер, но ключ — последовательность цифр (величины сдвига).',
    'cipherGronsfeldHelp': 'Введите цифровой ключ, например 31415.',
    'cipherTrithemius': 'Тритемиус',
    'cipherTrithemiusDesc':
        'Прогрессивный Цезарь: сдвиг 0, 1, 2, 3… для каждой следующей буквы.',
    'cipherTrithemiusHelp': 'Ключ не нужен — сдвиг равен позиции буквы.',
    'cipherPorta': 'Порта',
    'cipherPortaDesc':
        'Диграфический полиалфавитный шифр Порты. Нужен алфавит чётной длины.',
    'cipherPortaHelp':
        'Ключевое слово выбирает строки таблицы. Алфавит должен быть чётной длины.',
    'cipherRailFence': 'Рельсовый (Rail Fence)',
    'cipherRailFenceDesc':
        'Перестановочный шифр: буквы записываются зигзагом по рельсам.',
    'cipherRailFenceHelp':
        'Укажите число рельсов (≥ 2). Алфавит не меняется — меняется порядок букв.',
    'cipherColumnar': 'Столбцовая перестановка',
    'cipherColumnarDesc':
        'Текст пишется в таблицу по строкам и считывается по столбцам в порядке ключа.',
    'cipherColumnarHelp':
        'Ключевое слово задаёт порядок столбцов. Алфавит не подменяется.',
  };

  static const _en = {
    'appTagline':
        'A simple encoder and decoder with classic and modern ciphers',
    'chooseCipher': 'Choose a cipher',
    'appLanguage': 'App language',
    'themeToggle': 'Toggle theme',
    'open': 'Open',
    'example': 'Example',
    'back': 'Back',
    'help': 'Help',
    'alphabetLabel': 'Cipher alphabet',
    'originalAlphabet': 'Original alphabet',
    'modifiedAlphabet': 'Modified alphabet',
    'enterText': 'Enter text',
    'modifiedText': 'Modified text',
    'caesarKey': 'Key (shift)',
    'keyword': 'Keyword',
    'digitKey': 'Digit key',
    'affineA': 'Coefficient a',
    'affineB': 'Shift b',
    'rails': 'Number of rails',
    'customAlphabet': 'Custom alphabet…',
    'newAlphabetTitle': 'New alphabet',
    'alphabetName': 'Name',
    'alphabetLetters': 'Symbols in order',
    'save': 'Save',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'settings': 'Settings',
    'close': 'Close',
    'alphabetErrorEmpty': 'Enter a name and symbols',
    'alphabetErrorDuplicate': 'Alphabet must not contain duplicate symbols',
    'searchCipher': 'Search ciphers…',
    'allCategories': 'All',
    'noCiphersFound': 'No ciphers found',
    'categoryClassic': 'Classic',
    'categoryMono': 'Substitution',
    'categoryPoly': 'Polyalphabetic',
    'categoryTransposition': 'Transposition',
    'alphabetCatLetters': 'Letters',
    'alphabetCatDigits': 'Digits',
    'alphabetCatMixed': 'Mixed',
    'alphabetCatCustom': 'Custom',
    'affineNotCoprime': 'a must be coprime with the alphabet length',
    'alphabetRussian': 'Russian',
    'alphabetUkrainian': 'Ukrainian',
    'alphabetEnglish': 'English',
    'alphabetGerman': 'German',
    'alphabetFrench': 'French',
    'alphabetSpanish': 'Spanish',
    'alphabetItalian': 'Italian',
    'alphabetPolish': 'Polish',
    'alphabetTurkish': 'Turkish',
    'alphabetPortuguese': 'Portuguese',
    'alphabetGreek': 'Greek',
    'alphabetDutch': 'Dutch',
    'alphabetCzech': 'Czech',
    'alphabetSwedish': 'Swedish',
    'alphabetDigits09': 'Digits 0–9',
    'alphabetDigits19': 'Digits 1–9',
    'alphabetHex': 'Hexadecimal',
    'alphabetAlphanumeric': 'Latin + digits',
    'alphabetBinary': 'Binary (0/1)',
    'alphabetBase64': 'Base64',
    'cipherMirror': 'Mirror (Atbash)',
    'cipherMirrorDesc':
        'The alphabet is reversed: the first letter swaps with the last.',
    'cipherMirrorHelp':
        'Mirror (Atbash) replaces each letter with the one from the opposite end.\n\nNo extra keys needed.',
    'cipherCaesar': 'Caesar cipher',
    'cipherCaesarDesc':
        'Each letter is shifted by a fixed number of positions.',
    'cipherCaesarHelp':
        'Set the shift key. Type above to encrypt or below to decrypt.',
    'cipherRotHalf': 'ROT (half alphabet)',
    'cipherRotHalfDesc':
        'Fixed shift by half the alphabet length (ROT13 for English).',
    'cipherRotHalfHelp':
        'Requires an even-length alphabet. Encryption equals decryption.',
    'cipherKeywordCaesar': 'Keyword Caesar',
    'cipherKeywordCaesarDesc':
        'Unique keyword letters come first, then the rest of the alphabet.',
    'cipherKeywordCaesarHelp':
        'Enter a keyword using letters from the selected alphabet.',
    'cipherAffine': 'Affine cipher',
    'cipherAffineDesc':
        'Substitution via (a·x + b) mod n. a must be coprime with n.',
    'cipherAffineHelp':
        'Provide a and b. If a is not coprime with alphabet length, the app falls back safely.',
    'cipherOddEven': 'Odd-even',
    'cipherOddEvenDesc':
        'Even-indexed alphabet letters first, then odd-indexed ones.',
    'cipherOddEvenHelp': 'No key required. Simple alphabet reorder.',
    'cipherQwerty': 'QWERTY',
    'cipherQwertyDesc': 'Alphabet reordered to QWERTY keyboard order.',
    'cipherQwertyHelp': 'Latin alphabets only (English and similar).',
    'cipherYcuken': 'ЙЦУКЕН',
    'cipherYcukenDesc': 'Alphabet reordered to Russian ЙЦУКЕН layout.',
    'cipherYcukenHelp': 'Russian alphabet only.',
    'cipherVigenere': 'Vigenère',
    'cipherVigenereDesc':
        'Polyalphabetic cipher: shift changes with each keyword letter.',
    'cipherVigenereHelp':
        'Enter a keyword. Alphabet preview shows the shift of the first key letter.',
    'cipherBeaufort': 'Beaufort',
    'cipherBeaufortDesc':
        'Vigenère variant: C = (K − P) mod n. Encrypt equals decrypt.',
    'cipherBeaufortHelp': 'Requires a keyword from the alphabet.',
    'cipherVariantBeaufort': 'Variant Beaufort',
    'cipherVariantBeaufortDesc':
        'C = (P − K) mod n — another classic Vigenère variant.',
    'cipherVariantBeaufortHelp': 'Requires a keyword.',
    'cipherAutokey': 'Autokey',
    'cipherAutokeyDesc':
        'Vigenère where the key continues with the plaintext itself.',
    'cipherAutokeyHelp': 'Enter a primer (starting key).',
    'cipherGronsfeld': 'Gronsfeld',
    'cipherGronsfeldDesc':
        'Like Vigenère, but the key is a sequence of digit shifts.',
    'cipherGronsfeldHelp': 'Enter a digit key, e.g. 31415.',
    'cipherTrithemius': 'Trithemius',
    'cipherTrithemiusDesc':
        'Progressive Caesar: shifts 0, 1, 2, 3… for each next letter.',
    'cipherTrithemiusHelp': 'No key — shift equals letter position.',
    'cipherPorta': 'Porta',
    'cipherPortaDesc':
        'Porta polyalphabetic cipher. Requires an even-length alphabet.',
    'cipherPortaHelp':
        'The keyword selects table rows. Alphabet length must be even.',
    'cipherRailFence': 'Rail Fence',
    'cipherRailFenceDesc':
        'Transposition cipher: letters are written in a zigzag across rails.',
    'cipherRailFenceHelp':
        'Set rails (≥ 2). The alphabet stays the same — only letter order changes.',
    'cipherColumnar': 'Columnar transposition',
    'cipherColumnarDesc':
        'Text is written row-wise into a table and read by keyword-ordered columns.',
    'cipherColumnarHelp':
        'The keyword sets column order. No letter substitution.',
  };
}
