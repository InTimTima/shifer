import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ciphers/cipher_engine.dart';
import '../ciphers/cipher_factory.dart';
import '../l10n/app_strings.dart';
import '../models/alphabet.dart';
import '../models/cipher_info.dart';
import '../models/space_mode.dart';
import '../theme/shifer_theme.dart';
import '../widgets/cipher_text_field.dart';
import '../widgets/shifer_scope.dart';

class MixerScreen extends StatefulWidget {
  const MixerScreen({super.key});

  @override
  State<MixerScreen> createState() => _MixerScreenState();
}

class _MixerBlock {
  final Object id = Object();
  final CipherInfo info;
  CipherSettings settings;

  _MixerBlock(this.info, this.settings);
}

class _MixerScreenState extends State<MixerScreen> {
  final _inputController = TextEditingController();
  final _finalController = TextEditingController();
  final _finalFocus = FocusNode();
  Alphabet _baseAlphabet = BuiltinAlphabets.russian;
  final List<_MixerBlock> _blocks = [];

  @override
  void dispose() {
    _inputController.dispose();
    _finalController.dispose();
    _finalFocus.dispose();
    super.dispose();
  }

  CipherEngine _engineOf(_MixerBlock block) =>
      createCipher(block.info.kind, block.settings);

  Alphabet _inputAlphabetAt(int i) {
    if (i == 0) return _baseAlphabet;
    final prev = _blocks[i - 1];
    final prevEngine = _engineOf(prev);
    final prevInput = _inputAlphabetAt(i - 1);
    return prevEngine.isEncoding
        ? prevEngine.cipherSideAlphabet(prevInput)
        : prevInput;
  }

  String _inputTextAt(int i) {
    if (i == 0) return _inputController.text;
    return _outputTextAt(i - 1);
  }

  String _outputTextAt(int i) {
    final engine = _engineOf(_blocks[i]);
    return engine.encrypt(
      _inputTextAt(i),
      _inputAlphabetAt(i),
      spaceMode: SpaceMode.keep,
    );
  }

  bool _canAdd(CipherInfo info, int at) {
    return info.supportsAlphabet(_inputAlphabetAt(at));
  }

  /// Walks the chain backwards: final output → block N-1 decrypt → … → input.
  String _decryptChainBackwards(String finalOutput) {
    var text = finalOutput;
    for (var i = _blocks.length - 1; i >= 0; i--) {
      final engine = _engineOf(_blocks[i]);
      text = engine.decrypt(
        text,
        _inputAlphabetAt(i),
        spaceMode: SpaceMode.keep,
      );
    }
    return text;
  }

  /// Refreshes the editable final field from the forward chain, unless the
  /// user is currently typing there.
  void _syncFinalFromChain() {
    if (_blocks.isEmpty) {
      if (_finalController.text.isNotEmpty) _finalController.text = '';
      return;
    }
    if (_finalFocus.hasFocus) return;
    final computed = _outputTextAt(_blocks.length - 1);
    if (_finalController.text != computed) {
      _finalController.text = computed;
    }
  }

  void _onFinalChanged(String value) {
    if (_blocks.isEmpty) return;
    final plain = _decryptChainBackwards(value);
    _inputController.value = TextEditingValue(
      text: plain,
      selection: TextSelection.collapsed(offset: plain.length),
    );
    setState(() {});
    _syncFinalFromChain();
  }

  void _add(CipherInfo info, AppStrings strings) {
    if (!_canAdd(info, _blocks.length)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.mixerCannotAdd)),
      );
      return;
    }
    setState(() {
      _blocks.add(
        _MixerBlock(
          info,
          CipherSettings.demoFor(info.kind).copyWith(
            customCipherLetters: info.customCipherLetters ?? '',
          ),
        ),
      );
    });
    _syncFinalFromChain();
  }

  void _remove(_MixerBlock block) {
    setState(() => _blocks.remove(block));
    _syncFinalFromChain();
  }

  void _clear(AppStrings strings) {
    setState(() {
      _blocks.clear();
      _inputController.clear();
      _finalController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ShiferScope.settingsOf(context);
    final strings = AppStrings(settings.localeCode);
    final allCiphers = settings.allCiphers;
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 900;

    final addableAtEnd = <CipherInfo, bool>{
      for (final c in allCiphers) c: _canAdd(c, _blocks.length),
    };

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.mixerTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  strings.mixerSubtitle,
                  style: TextStyle(color: ShiferTheme.muted, height: 1.35),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              width: 270,
                              child: _CipherPalette(
                                ciphers: allCiphers,
                                canAdd: (c) => addableAtEnd[c] ?? false,
                                strings: strings,
                                onTap: (c) => _add(c, strings),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _Tower(
                                blocks: _blocks,
                                baseAlphabet: _baseAlphabet,
                                strings: strings,
                                inputController: _inputController,
                                finalController: _finalController,
                                finalFocus: _finalFocus,
                                onBaseChanged: (a) {
                                  setState(() => _baseAlphabet = a);
                                  _syncFinalFromChain();
                                },
                                inputTextAt: _inputTextAt,
                                outputTextAt: _outputTextAt,
                                inputAlphabetAt: _inputAlphabetAt,
                                onSettings: (block, s) {
                                  setState(() => block.settings = s);
                                  _syncFinalFromChain();
                                },
                                onInputChanged: () {
                                  setState(() {});
                                  _syncFinalFromChain();
                                },
                                onFinalChanged: _onFinalChanged,
                                onRemove: _remove,
                                onClear: () => _clear(strings),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            SizedBox(
                              height: 132,
                              child: _CipherPalette(
                                ciphers: allCiphers,
                                canAdd: (c) => addableAtEnd[c] ?? false,
                                strings: strings,
                                onTap: (c) => _add(c, strings),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: _Tower(
                                blocks: _blocks,
                                baseAlphabet: _baseAlphabet,
                                strings: strings,
                                inputController: _inputController,
                                finalController: _finalController,
                                finalFocus: _finalFocus,
                                onBaseChanged: (a) {
                                  setState(() => _baseAlphabet = a);
                                  _syncFinalFromChain();
                                },
                                inputTextAt: _inputTextAt,
                                outputTextAt: _outputTextAt,
                                inputAlphabetAt: _inputAlphabetAt,
                                onSettings: (block, s) {
                                  setState(() => block.settings = s);
                                  _syncFinalFromChain();
                                },
                                onInputChanged: () {
                                  setState(() {});
                                  _syncFinalFromChain();
                                },
                                onFinalChanged: _onFinalChanged,
                                onRemove: _remove,
                                onClear: () => _clear(strings),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CipherPalette extends StatelessWidget {
  final List<CipherInfo> ciphers;
  final bool Function(CipherInfo) canAdd;
  final AppStrings strings;
  final ValueChanged<CipherInfo> onTap;

  const _CipherPalette({
    required this.ciphers,
    required this.canAdd,
    required this.strings,
    required this.onTap,
  });

  String _categoryKey(CipherCategory category) {
    switch (category) {
      case CipherCategory.classic:
        return 'categoryClassic';
      case CipherCategory.monoalphabetic:
        return 'categoryMono';
      case CipherCategory.polyalphabetic:
        return 'categoryPoly';
      case CipherCategory.transposition:
        return 'categoryTransposition';
      case CipherCategory.encoding:
        return 'categoryEncoding';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ShiferTheme.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: ShiferTheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        itemCount: ciphers.length,
        itemBuilder: (context, i) {
          final c = ciphers[i];
          final allowed = canAdd(c);
          final name = c.isUserDefined
              ? c.nameKey
              : strings.t(c.nameKey);
          return Opacity(
            opacity: allowed ? 1 : 0.38,
            child: ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: Icon(
                allowed ? Icons.add_circle_outline : Icons.lock_outline,
                size: 18,
                color: allowed ? ShiferTheme.primary : ShiferTheme.muted,
              ),
              title: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: allowed ? ShiferTheme.text : ShiferTheme.muted,
                ),
              ),
              subtitle: Text(
                strings.t(_categoryKey(c.category)),
                style: const TextStyle(fontSize: 11),
              ),
              onTap: () => onTap(c),
            ),
          );
        },
      ),
    );
  }
}

class _Tower extends StatelessWidget {
  final List<_MixerBlock> blocks;
  final Alphabet baseAlphabet;
  final AppStrings strings;
  final TextEditingController inputController;
  final ValueChanged<Alphabet> onBaseChanged;
  final String Function(int) inputTextAt;
  final String Function(int) outputTextAt;
  final Alphabet Function(int) inputAlphabetAt;
  final void Function(_MixerBlock, CipherSettings) onSettings;
  final VoidCallback onInputChanged;
  final ValueChanged<String> onFinalChanged;
  final TextEditingController finalController;
  final FocusNode finalFocus;
  final ValueChanged<_MixerBlock> onRemove;
  final VoidCallback onClear;

  const _Tower({
    required this.blocks,
    required this.baseAlphabet,
    required this.strings,
    required this.inputController,
    required this.finalController,
    required this.finalFocus,
    required this.onBaseChanged,
    required this.inputTextAt,
    required this.outputTextAt,
    required this.inputAlphabetAt,
    required this.onSettings,
    required this.onInputChanged,
    required this.onFinalChanged,
    required this.onRemove,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: ShiferTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ShiferTheme.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_tree_outlined,
                size: 40, color: ShiferTheme.muted),
            const SizedBox(height: 10),
            Text(
              strings.mixerEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(color: ShiferTheme.muted),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: baseAlphabet.id,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: strings.mixerBaseAlphabet,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                items: [
                  for (final a in BuiltinAlphabets.all)
                    DropdownMenuItem(
                      value: a.id,
                      child: Text(strings.t(a.nameKey)),
                    ),
                ],
                onChanged: (id) {
                  if (id == null) return;
                  final a = BuiltinAlphabets.byId(id);
                  if (a != null) onBaseChanged(a);
                },
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.delete_sweep_outlined, size: 18),
              label: Text(strings.mixerClear),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 12),
            itemCount: blocks.length,
            itemBuilder: (context, i) {
              final block = blocks[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _BlockCard(
                  key: ValueKey(block.id),
                  index: i,
                  block: block,
                  strings: strings,
                  isFirst: i == 0,
                  isLast: i == blocks.length - 1,
                  inputController: inputController,
                  finalController: finalController,
                  finalFocus: finalFocus,
                  inputText: inputTextAt(i),
                  outputText: outputTextAt(i),
                  inputAlphabet: inputAlphabetAt(i),
                  onSettingsChanged: (s) => onSettings(block, s),
                  onInputChanged: onInputChanged,
                  onFinalChanged: onFinalChanged,
                  onRemove: () => onRemove(block),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BlockCard extends StatefulWidget {
  final int index;
  final _MixerBlock block;
  final AppStrings strings;
  final bool isFirst;
  final bool isLast;
  final TextEditingController inputController;
  final TextEditingController finalController;
  final FocusNode finalFocus;
  final String inputText;
  final String outputText;
  final Alphabet inputAlphabet;
  final ValueChanged<CipherSettings> onSettingsChanged;
  final VoidCallback onInputChanged;
  final ValueChanged<String> onFinalChanged;
  final VoidCallback onRemove;

  const _BlockCard({
    super.key,
    required this.index,
    required this.block,
    required this.strings,
    required this.isFirst,
    required this.isLast,
    required this.inputController,
    required this.finalController,
    required this.finalFocus,
    required this.inputText,
    required this.outputText,
    required this.inputAlphabet,
    required this.onSettingsChanged,
    required this.onInputChanged,
    required this.onFinalChanged,
    required this.onRemove,
  });

  @override
  State<_BlockCard> createState() => _BlockCardState();
}

class _BlockCardState extends State<_BlockCard> {
  late final TextEditingController _shiftController;
  late final TextEditingController _keywordController;
  late final TextEditingController _digitKeyController;
  late final TextEditingController _affineAController;
  late final TextEditingController _affineBController;
  late final TextEditingController _railsController;
  late final TextEditingController _diameterController;

  CipherSettings get _settings => widget.block.settings;

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  void _syncControllers() {
    _shiftController = TextEditingController(text: '${_settings.caesarShift}');
    _keywordController = TextEditingController(text: _settings.keyword);
    _digitKeyController = TextEditingController(text: _settings.digitKey);
    _affineAController = TextEditingController(text: '${_settings.affineA}');
    _affineBController = TextEditingController(text: '${_settings.affineB}');
    _railsController = TextEditingController(text: '${_settings.rails}');
    _diameterController = TextEditingController(text: '${_settings.diameter}');
  }

  @override
  void dispose() {
    _shiftController.dispose();
    _keywordController.dispose();
    _digitKeyController.dispose();
    _affineAController.dispose();
    _affineBController.dispose();
    _railsController.dispose();
    _diameterController.dispose();
    super.dispose();
  }

  void _update(CipherSettings next) {
    widget.onSettingsChanged(next);
  }

  List<Widget> _settingsFields() {
    final alphabet = widget.inputAlphabet;
    switch (widget.block.info.settingType) {
      case CipherSettingType.none:
        return const [];
      case CipherSettingType.shift:
        return [
          TextField(
            controller: _shiftController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'-?\d*')),
            ],
            decoration: InputDecoration(
              labelText: stringsOf.caesarKey,
              isDense: true,
            ),
            onChanged: (v) => _update(
              _settings.copyWith(caesarShift: int.tryParse(v) ?? 0),
            ),
          ),
        ];
      case CipherSettingType.keyword:
      case CipherSettingType.xorKey:
        return [
          TextField(
            controller: _keywordController,
            inputFormatters: [
              AlphabetInputFormatter(alphabet, allowSpaces: false),
            ],
            decoration: InputDecoration(
              labelText: stringsOf.keyword,
              isDense: true,
            ),
            onChanged: (v) => _update(_settings.copyWith(keyword: v)),
          ),
        ];
      case CipherSettingType.digitKey:
        return [
          TextField(
            controller: _digitKeyController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: stringsOf.digitKey,
              isDense: true,
            ),
            onChanged: (v) => _update(_settings.copyWith(digitKey: v)),
          ),
        ];
      case CipherSettingType.affine:
        return [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _affineAController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'-?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: stringsOf.affineA,
                    isDense: true,
                  ),
                  onChanged: (v) => _update(
                    _settings.copyWith(affineA: int.tryParse(v) ?? 1),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _affineBController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'-?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: stringsOf.affineB,
                    isDense: true,
                  ),
                  onChanged: (v) => _update(
                    _settings.copyWith(affineB: int.tryParse(v) ?? 0),
                  ),
                ),
              ),
            ],
          ),
        ];
      case CipherSettingType.rails:
        return [
          TextField(
            controller: _railsController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: stringsOf.rails,
              isDense: true,
            ),
            onChanged: (v) {
              final rails = int.tryParse(v) ?? 2;
              _update(_settings.copyWith(rails: rails < 2 ? 2 : rails));
            },
          ),
        ];
      case CipherSettingType.diameter:
        return [
          TextField(
            controller: _diameterController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: stringsOf.diameter,
              isDense: true,
            ),
            onChanged: (v) {
              final d = int.tryParse(v) ?? 2;
              _update(_settings.copyWith(diameter: d < 2 ? 2 : d));
            },
          ),
        ];
    }
  }

  AppStrings get stringsOf => widget.strings;

  @override
  Widget build(BuildContext context) {
    final info = widget.block.info;
    final engine = createCipher(info.kind, _settings);
    final name = info.isUserDefined ? info.nameKey : stringsOf.t(info.nameKey);
    final outputAlphabet = engine.isEncoding
        ? engine.cipherSideAlphabet(widget.inputAlphabet)
        : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ShiferTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ShiferTheme.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ShiferTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${widget.index + 1}',
                  style: TextStyle(
                    color: ShiferTheme.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                tooltip: stringsOf.delete,
                onPressed: widget.onRemove,
                icon: const Icon(Icons.close, size: 20),
                color: ShiferTheme.danger,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.isFirst)
            CipherTextField(
              controller: widget.inputController,
              hint: stringsOf.mixerInput,
              alphabet: widget.inputAlphabet,
              allowSpaces: true,
              onChanged: (_) => widget.onInputChanged(),
            )
          else
            _ValueBox(
              label: stringsOf.mixerInput,
              value: widget.inputText,
            ),
          if (_settingsFields().isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _settingsFields(),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _AlphabetStrip(
                  label: stringsOf.mixerAlphabetIn,
                  value: widget.inputAlphabet.lower,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AlphabetStrip(
                  label: stringsOf.mixerAlphabetOut,
                  value: outputAlphabet?.lower ??
                      engine.buildCipherAlphabet(widget.inputAlphabet),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (widget.isLast)
            CipherTextField(
              controller: widget.finalController,
              focusNode: widget.finalFocus,
              hint: stringsOf.mixerOutput,
              alphabet: engine.cipherSideAlphabet(widget.inputAlphabet),
              allowSpaces: true,
              extraAllowed: engine.isEncoding ? {'/', '|', '-'} : null,
              onChanged: widget.onFinalChanged,
            )
          else
            _ValueBox(
              label: stringsOf.mixerOutput,
              value: widget.outputText,
              highlight: true,
            ),
        ],
      ),
    );
  }
}

class _ValueBox extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _ValueBox({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: ShiferTheme.muted,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: highlight
                ? ShiferTheme.primary.withValues(alpha: 0.08)
                : ShiferTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: highlight ? ShiferTheme.primary : ShiferTheme.border,
            ),
          ),
          child: SelectableText(
            value.isEmpty ? '—' : value,
            maxLines: 3,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              height: 1.4,
              color: highlight ? ShiferTheme.primary : ShiferTheme.text,
            ),
          ),
        ),
      ],
    );
  }
}

class _AlphabetStrip extends StatelessWidget {
  final String label;
  final String value;

  const _AlphabetStrip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: ShiferTheme.muted,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ShiferTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ShiferTheme.border),
          ),
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              height: 1.35,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}