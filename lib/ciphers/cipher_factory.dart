import '../models/cipher_info.dart';
import 'cipher_engine.dart';
import 'encoding_ciphers.dart';
import 'extra_ciphers.dart';
import 'mono_ciphers.dart';
import 'poly_ciphers.dart';
import 'transposition_ciphers.dart';

class CipherSettings {
  final int caesarShift;
  final String keyword;
  final int affineA;
  final int affineB;
  final int rails;
  final String digitKey;
  final int diameter;
  final String customCipherLetters;

  const CipherSettings({
    this.caesarShift = 3,
    this.keyword = '',
    this.affineA = 5,
    this.affineB = 8,
    this.rails = 3,
    this.digitKey = '31415',
    this.diameter = 5,
    this.customCipherLetters = '',
  });

  CipherSettings copyWith({
    int? caesarShift,
    String? keyword,
    int? affineA,
    int? affineB,
    int? rails,
    String? digitKey,
    int? diameter,
    String? customCipherLetters,
  }) {
    return CipherSettings(
      caesarShift: caesarShift ?? this.caesarShift,
      keyword: keyword ?? this.keyword,
      affineA: affineA ?? this.affineA,
      affineB: affineB ?? this.affineB,
      rails: rails ?? this.rails,
      digitKey: digitKey ?? this.digitKey,
      diameter: diameter ?? this.diameter,
      customCipherLetters: customCipherLetters ?? this.customCipherLetters,
    );
  }

  static CipherSettings demoFor(CipherKind kind) {
    switch (kind) {
      case CipherKind.caesar:
        return const CipherSettings(caesarShift: 3);
      case CipherKind.keywordCaesar:
      case CipherKind.vigenere:
      case CipherKind.beaufort:
      case CipherKind.variantBeaufort:
      case CipherKind.autokey:
      case CipherKind.porta:
      case CipherKind.columnar:
      case CipherKind.playfair:
      case CipherKind.xor:
        return const CipherSettings(keyword: 'ключ');
      case CipherKind.affine:
        return const CipherSettings(affineA: 5, affineB: 8);
      case CipherKind.gronsfeld:
        return const CipherSettings(digitKey: '314');
      case CipherKind.railFence:
        return const CipherSettings(rails: 3);
      case CipherKind.scytale:
        return const CipherSettings(diameter: 5);
      default:
        return const CipherSettings();
    }
  }
}

CipherEngine createCipher(CipherKind kind, CipherSettings settings) {
  switch (kind) {
    case CipherKind.mirror:
      return MirrorCipher();
    case CipherKind.caesar:
      return CaesarCipher(shift: settings.caesarShift);
    case CipherKind.rotHalf:
      return RotHalfCipher();
    case CipherKind.keywordCaesar:
      return KeywordCaesarCipher(keyword: settings.keyword);
    case CipherKind.affine:
      return AffineCipher(a: settings.affineA, b: settings.affineB);
    case CipherKind.oddEven:
      return OddEvenCipher();
    case CipherKind.qwerty:
      return KeyboardLayoutCipher(layout: qwertyLayout);
    case CipherKind.ycuken:
      return KeyboardLayoutCipher(layout: ycukenLayout);
    case CipherKind.vigenere:
      return VigenereCipher(keyword: settings.keyword);
    case CipherKind.beaufort:
      return BeaufortCipher(keyword: settings.keyword);
    case CipherKind.variantBeaufort:
      return VariantBeaufortCipher(keyword: settings.keyword);
    case CipherKind.autokey:
      return AutokeyCipher(keyword: settings.keyword);
    case CipherKind.gronsfeld:
      return GronsfeldCipher(digitKey: settings.digitKey);
    case CipherKind.trithemius:
      return TrithemiusCipher();
    case CipherKind.porta:
      return PortaCipher(keyword: settings.keyword);
    case CipherKind.railFence:
      return RailFenceCipher(rails: settings.rails);
    case CipherKind.columnar:
      return ColumnarTranspositionCipher(keyword: settings.keyword);
    case CipherKind.morse:
      return MorseCipher();
    case CipherKind.braille:
      return BrailleCipher();
    case CipherKind.a1z26:
      return A1Z26Cipher();
    case CipherKind.nato:
      return NatoPhoneticCipher();
    case CipherKind.reverseText:
      return ReverseTextCipher();
    case CipherKind.bacon:
      return BaconCipher();
    case CipherKind.polybius:
      return PolybiusCipher();
    case CipherKind.binary:
      return BinaryCipher();
    case CipherKind.hex:
      return HexCipher();
    case CipherKind.base64:
      return Base64Cipher();
    case CipherKind.xor:
      return XorCipher(keyword: settings.keyword);
    case CipherKind.rot47:
      return Rot47Cipher();
    case CipherKind.tapCode:
      return TapCodeCipher();
    case CipherKind.playfair:
      return PlayfairCipher(keyword: settings.keyword);
    case CipherKind.scytale:
      return ScytaleCipher(diameter: settings.diameter);
    case CipherKind.customSub:
      return CustomSubstitutionCipher(
        cipherLetters: settings.customCipherLetters,
      );
  }
}
