import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ciphers/cipher_engine.dart';
import '../ciphers/cipher_factory.dart';
import '../l10n/app_strings.dart';
import '../models/alphabet.dart';
import '../models/cipher_info.dart';
import '../models/space_mode.dart';
import '../theme/shifer_theme.dart';
import '../widgets/alphabet_dropdown.dart';
import '../widgets/alphabet_panel.dart';
import '../widgets/cipher_text_field.dart';
import '../widgets/shifer_scope.dart';

enum _EditSource { none, plain, cipher }

class CipherScreen extends StatefulWidget {
  final CipherInfo info;

  const CipherScreen({super.key, required this.info});

  @override
  State<CipherScreen> createState() => _CipherScreenState();
}

class _CipherScreenState extends State<CipherScreen> {
  late Alphabet _alphabet;
  late SpaceMode _spaceMode;
  CipherSettings _settings = const CipherSettings();
  final _plainController = TextEditingController();
  final _cipherController = TextEditingController();
  final _plainFocus = FocusNode();
  final _cipherFocus = FocusNode();
  final _shiftController = TextEditingController(text: '3');
  final _keywordController = TextEditingController();
  final _digitKeyController = TextEditingController(text: '31415');
  final _affineAController = TextEditingController(text: '5');
  final _affineBController = TextEditingController(text: '8');
  final _railsController = TextEditingController(text: '3');
  _EditSource _source = _EditSource.none;

  final _diameterController = TextEditingController(text: '5');

  @override
  void initState() {
    super.initState();
    _settings = CipherSettings.demoFor(widget.info.kind).copyWith(
      customCipherLetters: widget.info.customCipherLetters ?? '',
    );
    _spaceMode = widget.info.defaultSpaceMode;
    _shiftController.text = '${_settings.caesarShift}';
    _keywordController.text = _settings.keyword;
    _digitKeyController.text = _settings.digitKey;
    _affineAController.text = '${_settings.affineA}';
    _affineBController.text = '${_settings.affineB}';
    _railsController.text = '${_settings.rails}';
    _diameterController.text = '${_settings.diameter}';
    _alphabet = _defaultAlphabet();
  }

  Alphabet _defaultAlphabet() {
    if (widget.info.baseAlphabetId != null) {
      final match = BuiltinAlphabets.byId(widget.info.baseAlphabetId!);
      if (match != null) return match;
    }
    final preferred = [
      BuiltinAlphabets.russian,
      BuiltinAlphabets.english,
      ...BuiltinAlphabets.all,
    ];
    for (final a in preferred) {
      if (widget.info.supportsAlphabet(a)) return a;
    }
    return BuiltinAlphabets.english;
  }

  @override
  void dispose() {
    _plainController.dispose();
    _cipherController.dispose();
    _plainFocus.dispose();
    _cipherFocus.dispose();
    _shiftController.dispose();
    _keywordController.dispose();
    _digitKeyController.dispose();
    _affineAController.dispose();
    _affineBController.dispose();
    _railsController.dispose();
    _diameterController.dispose();
    super.dispose();
  }

  CipherEngine get _engine => createCipher(widget.info.kind, _settings);

  bool get _allowSpaces =>
      widget.info.spaceSupport != SpaceSupport.none;

  String get _cipherAlphabetPreview {
    final tokens = _engine.cipherInsertTokens(_alphabet);
    if (tokens != null && tokens.isNotEmpty) {
      return tokens.join();
    }
    return _engine.buildCipherAlphabet(_alphabet);
  }

  Alphabet get _cipherFilterAlphabet =>
      _engine.cipherSideAlphabet(_alphabet);

  List<Alphabet> _compatibleAlphabets(List<Alphabet> all) =>
      all.where(widget.info.supportsAlphabet).toList();

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _onPlainChanged(String value) {
    _source = _EditSource.plain;
    final filtered = _engine.filterInput(
      value,
      _alphabet,
      allowSpaces: _allowSpaces,
    );
    if (filtered != value) {
      final sel = _plainController.selection;
      _plainController.value = TextEditingValue(
        text: filtered,
        selection: TextSelection.collapsed(
          offset: sel.baseOffset.clamp(0, filtered.length),
        ),
      );
    }
    final encoded = _engine.encrypt(
      filtered,
      _alphabet,
      spaceMode: _spaceMode,
    );
    _cipherController.value = TextEditingValue(
      text: encoded,
      selection: TextSelection.collapsed(offset: encoded.length),
    );
    _source = _EditSource.none;
  }

  void _onCipherChanged(String value) {
    _source = _EditSource.cipher;
    final filtered = _engine.isEncoding
        ? _engine.filterCipherInput(
            value,
            _alphabet,
            allowSpaces: _allowSpaces,
          )
        : _engine.filterInput(
            value,
            _alphabet,
            allowSpaces: _allowSpaces,
          );
    if (filtered != value) {
      final sel = _cipherController.selection;
      _cipherController.value = TextEditingValue(
        text: filtered,
        selection: TextSelection.collapsed(
          offset: sel.baseOffset.clamp(0, filtered.length),
        ),
      );
    }
    final decoded = _engine.decrypt(
      filtered,
      _alphabet,
      spaceMode: _spaceMode,
    );
    _plainController.value = TextEditingValue(
      text: decoded,
      selection: TextSelection.collapsed(offset: decoded.length),
    );
    _source = _EditSource.none;
  }

  void _recomputeFromSource() {
    if (_source == _EditSource.cipher) {
      _onCipherChanged(_cipherController.text);
    } else {
      _onPlainChanged(_plainController.text);
    }
  }

  void _insertPlain(String value) {
    // Always append — chip taps unfocus the field and can report a bogus
    // full selection that would otherwise replace the whole string.
    final next = '${_plainController.text}$value';
    _plainController.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
    _onPlainChanged(next);
    _plainFocus.requestFocus();
  }

  void _insertCipher(String value) {
    // Encoding ciphers use space as a letter separator between multi-char
    // tokens (Morse '.−', NATO 'Alpha', …). Auto-append it so every click
    // produces a complete, decodable token instead of glued characters.
    final token =
        _engine.isEncoding && value.runes.length > 1 ? '$value ' : value;
    final next = '${_cipherController.text}$token';
    _cipherController.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
    _onCipherChanged(next);
    _cipherFocus.requestFocus();
  }

  void _setAlphabet(Alphabet alphabet) {
    setState(() => _alphabet = alphabet);
    if (widget.info.settingType == CipherSettingType.keyword) {
      final filtered =
          _engine.filterInput(_keywordController.text, alphabet, allowSpaces: false);
      _keywordController.text = filtered;
      _settings = _settings.copyWith(keyword: filtered);
    }
    _recomputeFromSource();
  }

  Future<void> _createCustomAlphabet() async {
    final settings = ShiferScope.settingsOf(context);
    final strings = AppStrings(settings.localeCode);
    final created = await showCustomAlphabetDialog(
      context: context,
      strings: strings,
      settings: settings,
    );
    if (created != null && mounted) {
      if (widget.info.supportsAlphabet(created)) {
        _setAlphabet(created);
      } else {
        setState(() {});
      }
    }
  }

  Future<void> _deleteCustom(Alphabet alphabet) async {
    final settings = ShiferScope.settingsOf(context);
    await settings.removeCustomAlphabet(alphabet.id);
    if (_alphabet.id == alphabet.id) {
      _setAlphabet(_defaultAlphabet());
    } else {
      setState(() {});
    }
  }

  void _showHelp(AppStrings strings) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.t(widget.info.nameKey)),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Text(strings.t(widget.info.helpKey)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.close),
          ),
        ],
      ),
    );
  }

  Widget _spaceControls(AppStrings strings) {
    switch (widget.info.spaceSupport) {
      case SpaceSupport.none:
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            strings.spaceUnsupported,
            style: const TextStyle(fontSize: 12, color: Colors.orangeAccent),
          ),
        );
      case SpaceSupport.keep:
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            strings.spaceKeepHint,
            style: TextStyle(fontSize: 12, color: ShiferTheme.muted),
          ),
        );
      case SpaceSupport.choosable:
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings.spaceModeLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ShiferTheme.muted,
                ),
              ),
              const SizedBox(height: 6),
              SegmentedButton<SpaceMode>(
                segments: [
                  ButtonSegment(
                    value: SpaceMode.keep,
                    label: Text(strings.spaceKeep),
                  ),
                  ButtonSegment(
                    value: SpaceMode.perWord,
                    label: Text(strings.spacePerWord),
                  ),
                ],
                selected: {_spaceMode},
                onSelectionChanged: (set) {
                  setState(() => _spaceMode = set.first);
                  _recomputeFromSource();
                },
              ),
              const SizedBox(height: 4),
              Text(
                _spaceMode == SpaceMode.keep
                    ? strings.spaceKeepHint
                    : strings.spacePerWordHint,
style: TextStyle(fontSize: 12, color: ShiferTheme.muted),
              ),
            ],
          ),
        );
    }
  }

  Widget _settingsFields(AppStrings strings) {
    switch (widget.info.settingType) {
      case CipherSettingType.none:
        return const SizedBox.shrink();
      case CipherSettingType.shift:
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: TextField(
            controller: _shiftController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'-?\d*')),
            ],
            decoration: InputDecoration(labelText: strings.caesarKey),
            onChanged: (v) {
              final shift = int.tryParse(v) ?? 0;
              setState(() {
                _settings = _settings.copyWith(caesarShift: shift);
              });
              _recomputeFromSource();
            },
          ),
        );
      case CipherSettingType.keyword:
      case CipherSettingType.xorKey:
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: TextField(
            controller: _keywordController,
            inputFormatters: [
              AlphabetInputFormatter(_alphabet, allowSpaces: false),
            ],
            decoration: InputDecoration(labelText: strings.keyword),
            onChanged: (v) {
              setState(() {
                _settings = _settings.copyWith(keyword: v);
              });
              _recomputeFromSource();
            },
          ),
        );
      case CipherSettingType.digitKey:
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: TextField(
            controller: _digitKeyController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: strings.digitKey),
            onChanged: (v) {
              setState(() {
                _settings = _settings.copyWith(digitKey: v);
              });
              _recomputeFromSource();
            },
          ),
        );
      case CipherSettingType.affine:
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _affineAController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'-?\d*')),
                  ],
                  decoration: InputDecoration(labelText: strings.affineA),
                  onChanged: (v) {
                    final a = int.tryParse(v) ?? 1;
                    setState(() {
                      _settings = _settings.copyWith(affineA: a);
                    });
                    _recomputeFromSource();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _affineBController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'-?\d*')),
                  ],
                  decoration: InputDecoration(labelText: strings.affineB),
                  onChanged: (v) {
                    final b = int.tryParse(v) ?? 0;
                    setState(() {
                      _settings = _settings.copyWith(affineB: b);
                    });
                    _recomputeFromSource();
                  },
                ),
              ),
            ],
          ),
        );
      case CipherSettingType.rails:
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: TextField(
            controller: _railsController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: strings.rails),
            onChanged: (v) {
              final rails = int.tryParse(v) ?? 2;
              setState(() {
                _settings = _settings.copyWith(rails: rails < 2 ? 2 : rails);
              });
              _recomputeFromSource();
            },
          ),
        );
      case CipherSettingType.diameter:
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: TextField(
            controller: _diameterController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: strings.diameter),
            onChanged: (v) {
              final d = int.tryParse(v) ?? 2;
              setState(() {
                _settings = _settings.copyWith(diameter: d < 2 ? 2 : d);
              });
              _recomputeFromSource();
            },
          ),
        );
    }
  }

  Widget _alphabetPanels(AppStrings strings, bool isWide) {
    final original = AlphabetPanel(
      title: strings.originalAlphabet,
      letters: _alphabet.lower,
      hint: strings.clickAlphabetHint,
      onInsert: _insertPlain,
    );
    final modified = AlphabetPanel(
      title: strings.modifiedAlphabet,
      letters: _cipherAlphabetPreview,
      tokens: _engine.cipherInsertTokens(_alphabet),
      hint: strings.clickAlphabetHint,
      onInsert: _insertCipher,
    );

    if (isWide) {
      return Row(
        children: [
          Expanded(child: original),
          const SizedBox(width: 12),
          Expanded(child: modified),
        ],
      );
    }
    return Column(
      children: [
        Expanded(child: original),
        const SizedBox(height: 10),
        Expanded(child: modified),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = ShiferScope.settingsOf(context);
    final strings = AppStrings(appSettings.localeCode);
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 700;
    final alphabets = _compatibleAlphabets(appSettings.allAlphabets);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): _goBack,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TitleBar(
                        title: widget.info.isUserDefined
                            ? widget.info.nameKey
                            : strings.t(widget.info.nameKey),
                        helpTooltip: strings.help,
                        onHelp: () => _showHelp(strings),
                      ),
                      const SizedBox(height: 12),
                      AlphabetDropdown(
                        value: alphabets.any((a) => a.id == _alphabet.id)
                            ? _alphabet
                            : alphabets.first,
                        alphabets: alphabets,
                        strings: strings,
                        onChanged: _setAlphabet,
                        onCreateCustom: _createCustomAlphabet,
                        onDeleteCustom: _deleteCustom,
                      ),
                      _settingsFields(strings),
                      _spaceControls(strings),
                      if (widget.info.settingType == CipherSettingType.affine &&
                          gcd(_settings.affineA, _alphabet.length) != 1) ...[
                        const SizedBox(height: 6),
                        Text(
                          strings.affineNotCoprime,
                          style: const TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      CipherTextField(
                        controller: _plainController,
                        focusNode: _plainFocus,
                        hint: strings.enterText,
                        alphabet: _alphabet,
                        allowSpaces: _allowSpaces,
                        onChanged: _onPlainChanged,
                      ),
                      const SizedBox(height: 12),
                      Expanded(child: _alphabetPanels(strings, isWide)),
                      const SizedBox(height: 12),
                      CipherTextField(
                        controller: _cipherController,
                        focusNode: _cipherFocus,
                        hint: strings.modifiedText,
                        alphabet: _cipherFilterAlphabet,
                        allowSpaces: _allowSpaces,
                        extraAllowed: _engine.isEncoding
                            ? {'/', '|', '-'}
                            : null,
                        onChanged: _onCipherChanged,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          onPressed: _goBack,
                          child: Text(strings.back),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleBar extends StatelessWidget {
  final String title;
  final String helpTooltip;
  final VoidCallback onHelp;

  const _TitleBar({
    required this.title,
    required this.helpTooltip,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: ShiferTheme.text,
            ),
          ),
        ),
        Tooltip(
          message: helpTooltip,
          child: IconButton(
            onPressed: onHelp,
            icon: const Icon(Icons.help_outline),
            color: ShiferTheme.primary,
          ),
        ),
      ],
    );
  }
}
