import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/alphabet.dart';
import '../models/cipher_info.dart';
import '../models/custom_cipher.dart';
import '../models/space_mode.dart';

class AppSettings extends ChangeNotifier {
  static const _localeKey = 'app_locale';
  static const _themeKey = 'app_theme';
  static const _customAlphabetsKey = 'custom_alphabets';
  static const _customCiphersKey = 'custom_ciphers';

  String _localeCode = 'ru';
  Brightness _brightness = Brightness.dark;
  List<Alphabet> _customAlphabets = [];
  List<CustomCipherDef> _customCiphers = [];

  String get localeCode => _localeCode;
  Brightness get brightness => _brightness;
  bool get isDark => _brightness == Brightness.dark;
  List<Alphabet> get customAlphabets => List.unmodifiable(_customAlphabets);
  List<CustomCipherDef> get customCiphers => List.unmodifiable(_customCiphers);

  List<Alphabet> get allAlphabets => [
        ...BuiltinAlphabets.all,
        ..._customAlphabets,
      ];

  List<CipherInfo> get allCiphers => [
        ...availableCiphers,
        ..._customCiphers.map(_toCipherInfo),
      ];

  CipherInfo _toCipherInfo(CustomCipherDef def) => CipherInfo(
        kind: CipherKind.customSub,
        category: CipherCategory.monoalphabetic,
        settingType: CipherSettingType.none,
        spaceSupport: SpaceSupport.keep,
        nameKey: def.name,
        descriptionKey: def.description.isEmpty
            ? 'cipherCustomDesc'
            : def.description,
        helpKey: 'cipherCustomHelp',
        isUserDefined: true,
        customCipherLetters: def.cipherLetters,
        baseAlphabetId: def.baseAlphabetId,
      );

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _localeCode = prefs.getString(_localeKey) ?? 'ru';
    _brightness = prefs.getString(_themeKey) == 'light'
        ? Brightness.light
        : Brightness.dark;
    final rawAlpha = prefs.getStringList(_customAlphabetsKey) ?? [];
    _customAlphabets = rawAlpha
        .map((e) => Alphabet.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
    final rawCiphers = prefs.getStringList(_customCiphersKey) ?? [];
    _customCiphers =
        rawCiphers.map(CustomCipherDef.fromJsonString).toList();
    notifyListeners();
  }

  Future<void> setLocale(String code) async {
    if (_localeCode == code) return;
    _localeCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, code);
    notifyListeners();
  }

  Future<void> setBrightness(Brightness value) async {
    if (_brightness == value) return;
    _brightness = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _themeKey,
      value == Brightness.dark ? 'dark' : 'light',
    );
    notifyListeners();
  }

  Future<void> addCustomAlphabet(Alphabet alphabet) async {
    _customAlphabets = [..._customAlphabets, alphabet];
    await _persistAlphabets();
    notifyListeners();
  }

  Future<void> removeCustomAlphabet(String id) async {
    _customAlphabets = _customAlphabets.where((a) => a.id != id).toList();
    await _persistAlphabets();
    notifyListeners();
  }

  Future<void> addCustomCipher(CustomCipherDef cipher) async {
    _customCiphers = [..._customCiphers, cipher];
    await _persistCiphers();
    notifyListeners();
  }

  Future<void> removeCustomCipher(String id) async {
    _customCiphers = _customCiphers.where((c) => c.id != id).toList();
    await _persistCiphers();
    notifyListeners();
  }

  Future<void> _persistAlphabets() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        _customAlphabets.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList(_customAlphabetsKey, encoded);
  }

  Future<void> _persistCiphers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _customCiphersKey,
      _customCiphers.map((c) => c.toJsonString()).toList(),
    );
  }

  Alphabet? findAlphabet(String id) {
    final builtin = BuiltinAlphabets.byId(id);
    if (builtin != null) return builtin;
    for (final a in _customAlphabets) {
      if (a.id == id) return a;
    }
    return null;
  }
}
