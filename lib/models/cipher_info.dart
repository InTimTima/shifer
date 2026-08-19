import 'alphabet.dart';
import 'space_mode.dart';

enum CipherCategory {
  classic,
  monoalphabetic,
  polyalphabetic,
  transposition,
  encoding,
}

enum CipherSettingType {
  none,
  shift,
  keyword,
  affine,
  rails,
  digitKey,
  diameter,
  xorKey,
}

enum CipherKind {
  mirror,
  caesar,
  rotHalf,
  keywordCaesar,
  affine,
  oddEven,
  qwerty,
  ycuken,
  vigenere,
  beaufort,
  variantBeaufort,
  autokey,
  gronsfeld,
  trithemius,
  porta,
  railFence,
  columnar,
  morse,
  braille,
  a1z26,
  nato,
  reverseText,
  bacon,
  polybius,
  binary,
  hex,
  base64,
  xor,
  rot47,
  tapCode,
  playfair,
  scytale,
  customSub,
}

class CipherInfo {
  final CipherKind kind;
  final CipherCategory category;
  final CipherSettingType settingType;
  final SpaceSupport spaceSupport;
  final String nameKey;
  final String descriptionKey;
  final String helpKey;
  final Set<AlphabetCategory>? allowedAlphabetCategories;
  final bool Function(Alphabet alphabet)? isAlphabetCompatible;
  final bool isUserDefined;
  final String? customCipherLetters;
  final String? baseAlphabetId;

  const CipherInfo({
    required this.kind,
    required this.category,
    required this.settingType,
    required this.nameKey,
    required this.descriptionKey,
    required this.helpKey,
    this.spaceSupport = SpaceSupport.keep,
    this.allowedAlphabetCategories,
    this.isAlphabetCompatible,
    this.isUserDefined = false,
    this.customCipherLetters,
    this.baseAlphabetId,
  });

  bool supportsAlphabet(Alphabet alphabet) {
    if (isAlphabetCompatible != null && !isAlphabetCompatible!(alphabet)) {
      return false;
    }
    if (alphabet.isCustom) return true;
    if (allowedAlphabetCategories != null &&
        !allowedAlphabetCategories!.contains(alphabet.category)) {
      return false;
    }
    return true;
  }

  SpaceMode get defaultSpaceMode {
    switch (spaceSupport) {
      case SpaceSupport.keep:
      case SpaceSupport.choosable:
        return SpaceMode.keep;
      case SpaceSupport.none:
        return SpaceMode.keep;
    }
  }
}

bool _evenLength(Alphabet a) => a.length % 2 == 0;

bool _minLength2(Alphabet a) => a.length >= 2;

bool _isLatinLetters(Alphabet a) => a.id == 'en' || a.id == 'nl' || a.id == 'it';

bool _isRussianLetters(Alphabet a) => a.id == 'ru';

bool _morseCompatible(Alphabet a) =>
    a.category == AlphabetCategory.letters || a.isCustom;

bool _brailleCompatible(Alphabet a) =>
    a.id == 'ru' ||
    a.id == 'uk' ||
    a.id == 'en' ||
    a.id == 'nl' ||
    a.id == 'it' ||
    a.isCustom;

bool _natoCompatible(Alphabet a) =>
    a.id == 'en' || a.id == 'nl' || a.id == 'it' || a.isCustom;

final List<CipherInfo> availableCiphers = [
  const CipherInfo(
    kind: CipherKind.mirror,
    category: CipherCategory.classic,
    settingType: CipherSettingType.none,
    nameKey: 'cipherMirror',
    descriptionKey: 'cipherMirrorDesc',
    helpKey: 'cipherMirrorHelp',
  ),
  const CipherInfo(
    kind: CipherKind.caesar,
    category: CipherCategory.classic,
    settingType: CipherSettingType.shift,
    nameKey: 'cipherCaesar',
    descriptionKey: 'cipherCaesarDesc',
    helpKey: 'cipherCaesarHelp',
  ),
  const CipherInfo(
    kind: CipherKind.rotHalf,
    category: CipherCategory.classic,
    settingType: CipherSettingType.none,
    nameKey: 'cipherRotHalf',
    descriptionKey: 'cipherRotHalfDesc',
    helpKey: 'cipherRotHalfHelp',
    isAlphabetCompatible: _evenLength,
  ),
  const CipherInfo(
    kind: CipherKind.keywordCaesar,
    category: CipherCategory.monoalphabetic,
    settingType: CipherSettingType.keyword,
    nameKey: 'cipherKeywordCaesar',
    descriptionKey: 'cipherKeywordCaesarDesc',
    helpKey: 'cipherKeywordCaesarHelp',
  ),
  const CipherInfo(
    kind: CipherKind.affine,
    category: CipherCategory.monoalphabetic,
    settingType: CipherSettingType.affine,
    nameKey: 'cipherAffine',
    descriptionKey: 'cipherAffineDesc',
    helpKey: 'cipherAffineHelp',
  ),
  const CipherInfo(
    kind: CipherKind.oddEven,
    category: CipherCategory.monoalphabetic,
    settingType: CipherSettingType.none,
    nameKey: 'cipherOddEven',
    descriptionKey: 'cipherOddEvenDesc',
    helpKey: 'cipherOddEvenHelp',
  ),
  const CipherInfo(
    kind: CipherKind.qwerty,
    category: CipherCategory.monoalphabetic,
    settingType: CipherSettingType.none,
    nameKey: 'cipherQwerty',
    descriptionKey: 'cipherQwertyDesc',
    helpKey: 'cipherQwertyHelp',
    allowedAlphabetCategories: {AlphabetCategory.letters},
    isAlphabetCompatible: _isLatinLetters,
  ),
  const CipherInfo(
    kind: CipherKind.ycuken,
    category: CipherCategory.monoalphabetic,
    settingType: CipherSettingType.none,
    nameKey: 'cipherYcuken',
    descriptionKey: 'cipherYcukenDesc',
    helpKey: 'cipherYcukenHelp',
    allowedAlphabetCategories: {AlphabetCategory.letters},
    isAlphabetCompatible: _isRussianLetters,
  ),
  const CipherInfo(
    kind: CipherKind.vigenere,
    category: CipherCategory.polyalphabetic,
    settingType: CipherSettingType.keyword,
    nameKey: 'cipherVigenere',
    descriptionKey: 'cipherVigenereDesc',
    helpKey: 'cipherVigenereHelp',
  ),
  const CipherInfo(
    kind: CipherKind.beaufort,
    category: CipherCategory.polyalphabetic,
    settingType: CipherSettingType.keyword,
    nameKey: 'cipherBeaufort',
    descriptionKey: 'cipherBeaufortDesc',
    helpKey: 'cipherBeaufortHelp',
  ),
  const CipherInfo(
    kind: CipherKind.variantBeaufort,
    category: CipherCategory.polyalphabetic,
    settingType: CipherSettingType.keyword,
    nameKey: 'cipherVariantBeaufort',
    descriptionKey: 'cipherVariantBeaufortDesc',
    helpKey: 'cipherVariantBeaufortHelp',
  ),
  const CipherInfo(
    kind: CipherKind.autokey,
    category: CipherCategory.polyalphabetic,
    settingType: CipherSettingType.keyword,
    nameKey: 'cipherAutokey',
    descriptionKey: 'cipherAutokeyDesc',
    helpKey: 'cipherAutokeyHelp',
  ),
  const CipherInfo(
    kind: CipherKind.gronsfeld,
    category: CipherCategory.polyalphabetic,
    settingType: CipherSettingType.digitKey,
    nameKey: 'cipherGronsfeld',
    descriptionKey: 'cipherGronsfeldDesc',
    helpKey: 'cipherGronsfeldHelp',
  ),
  const CipherInfo(
    kind: CipherKind.trithemius,
    category: CipherCategory.polyalphabetic,
    settingType: CipherSettingType.none,
    nameKey: 'cipherTrithemius',
    descriptionKey: 'cipherTrithemiusDesc',
    helpKey: 'cipherTrithemiusHelp',
  ),
  const CipherInfo(
    kind: CipherKind.porta,
    category: CipherCategory.polyalphabetic,
    settingType: CipherSettingType.keyword,
    nameKey: 'cipherPorta',
    descriptionKey: 'cipherPortaDesc',
    helpKey: 'cipherPortaHelp',
    isAlphabetCompatible: _evenLength,
  ),
  const CipherInfo(
    kind: CipherKind.railFence,
    category: CipherCategory.transposition,
    settingType: CipherSettingType.rails,
    spaceSupport: SpaceSupport.choosable,
    nameKey: 'cipherRailFence',
    descriptionKey: 'cipherRailFenceDesc',
    helpKey: 'cipherRailFenceHelp',
    isAlphabetCompatible: _minLength2,
  ),
  const CipherInfo(
    kind: CipherKind.columnar,
    category: CipherCategory.transposition,
    settingType: CipherSettingType.keyword,
    spaceSupport: SpaceSupport.choosable,
    nameKey: 'cipherColumnar',
    descriptionKey: 'cipherColumnarDesc',
    helpKey: 'cipherColumnarHelp',
  ),
  const CipherInfo(
    kind: CipherKind.morse,
    category: CipherCategory.encoding,
    settingType: CipherSettingType.none,
    nameKey: 'cipherMorse',
    descriptionKey: 'cipherMorseDesc',
    helpKey: 'cipherMorseHelp',
    allowedAlphabetCategories: {AlphabetCategory.letters},
    isAlphabetCompatible: _morseCompatible,
  ),
  const CipherInfo(
    kind: CipherKind.braille,
    category: CipherCategory.encoding,
    settingType: CipherSettingType.none,
    nameKey: 'cipherBraille',
    descriptionKey: 'cipherBrailleDesc',
    helpKey: 'cipherBrailleHelp',
    allowedAlphabetCategories: {AlphabetCategory.letters},
    isAlphabetCompatible: _brailleCompatible,
  ),
  const CipherInfo(
    kind: CipherKind.a1z26,
    category: CipherCategory.encoding,
    settingType: CipherSettingType.none,
    nameKey: 'cipherA1z26',
    descriptionKey: 'cipherA1z26Desc',
    helpKey: 'cipherA1z26Help',
  ),
  const CipherInfo(
    kind: CipherKind.nato,
    category: CipherCategory.encoding,
    settingType: CipherSettingType.none,
    nameKey: 'cipherNato',
    descriptionKey: 'cipherNatoDesc',
    helpKey: 'cipherNatoHelp',
    allowedAlphabetCategories: {AlphabetCategory.letters},
    isAlphabetCompatible: _natoCompatible,
  ),
  const CipherInfo(
    kind: CipherKind.reverseText,
    category: CipherCategory.transposition,
    settingType: CipherSettingType.none,
    spaceSupport: SpaceSupport.choosable,
    nameKey: 'cipherReverse',
    descriptionKey: 'cipherReverseDesc',
    helpKey: 'cipherReverseHelp',
  ),
  const CipherInfo(
    kind: CipherKind.bacon,
    category: CipherCategory.encoding,
    settingType: CipherSettingType.none,
    nameKey: 'cipherBacon',
    descriptionKey: 'cipherBaconDesc',
    helpKey: 'cipherBaconHelp',
  ),
  const CipherInfo(
    kind: CipherKind.polybius,
    category: CipherCategory.encoding,
    settingType: CipherSettingType.none,
    nameKey: 'cipherPolybius',
    descriptionKey: 'cipherPolybiusDesc',
    helpKey: 'cipherPolybiusHelp',
  ),
  const CipherInfo(
    kind: CipherKind.binary,
    category: CipherCategory.encoding,
    settingType: CipherSettingType.none,
    nameKey: 'cipherBinary',
    descriptionKey: 'cipherBinaryDesc',
    helpKey: 'cipherBinaryHelp',
  ),
  const CipherInfo(
    kind: CipherKind.hex,
    category: CipherCategory.encoding,
    settingType: CipherSettingType.none,
    nameKey: 'cipherHex',
    descriptionKey: 'cipherHexDesc',
    helpKey: 'cipherHexHelp',
  ),
  const CipherInfo(
    kind: CipherKind.base64,
    category: CipherCategory.encoding,
    settingType: CipherSettingType.none,
    nameKey: 'cipherBase64',
    descriptionKey: 'cipherBase64Desc',
    helpKey: 'cipherBase64Help',
  ),
  const CipherInfo(
    kind: CipherKind.xor,
    category: CipherCategory.polyalphabetic,
    settingType: CipherSettingType.xorKey,
    nameKey: 'cipherXor',
    descriptionKey: 'cipherXorDesc',
    helpKey: 'cipherXorHelp',
  ),
  const CipherInfo(
    kind: CipherKind.rot47,
    category: CipherCategory.classic,
    settingType: CipherSettingType.none,
    nameKey: 'cipherRot47',
    descriptionKey: 'cipherRot47Desc',
    helpKey: 'cipherRot47Help',
  ),
  const CipherInfo(
    kind: CipherKind.tapCode,
    category: CipherCategory.encoding,
    settingType: CipherSettingType.none,
    nameKey: 'cipherTapCode',
    descriptionKey: 'cipherTapCodeDesc',
    helpKey: 'cipherTapCodeHelp',
  ),
  const CipherInfo(
    kind: CipherKind.playfair,
    category: CipherCategory.monoalphabetic,
    settingType: CipherSettingType.keyword,
    nameKey: 'cipherPlayfair',
    descriptionKey: 'cipherPlayfairDesc',
    helpKey: 'cipherPlayfairHelp',
  ),
  const CipherInfo(
    kind: CipherKind.scytale,
    category: CipherCategory.transposition,
    settingType: CipherSettingType.diameter,
    spaceSupport: SpaceSupport.choosable,
    nameKey: 'cipherScytale',
    descriptionKey: 'cipherScytaleDesc',
    helpKey: 'cipherScytaleHelp',
  ),
];

List<CipherInfo> ciphersInCategory(CipherCategory category) =>
    availableCiphers.where((c) => c.category == category).toList();
