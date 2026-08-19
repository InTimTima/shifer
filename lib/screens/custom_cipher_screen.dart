import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ciphers/cipher_engine.dart';
import '../ciphers/extra_ciphers.dart';
import '../l10n/app_strings.dart';
import '../models/alphabet.dart';
import '../models/custom_cipher.dart';
import '../theme/shifer_theme.dart';
import '../widgets/shifer_scope.dart';
import 'cipher_screen.dart';

enum _RuleType { shift, mirror, keyword, custom, affine, rotHalf, oddEven }

class _RuleStep {
  final int id;
  _RuleType type;
  int shift;
  String keyword;
  String custom;
  int affineA;
  int affineB;

  _RuleStep({
    required this.id,
    this.type = _RuleType.shift,
    this.shift = 3,
    this.keyword = '',
    this.custom = '',
    this.affineA = 5,
    this.affineB = 8,
  });

  _RuleStep copyWith({
    _RuleType? type,
    int? shift,
    String? keyword,
    String? custom,
    int? affineA,
    int? affineB,
  }) {
    return _RuleStep(
      id: id,
      type: type ?? this.type,
      shift: shift ?? this.shift,
      keyword: keyword ?? this.keyword,
      custom: custom ?? this.custom,
      affineA: affineA ?? this.affineA,
      affineB: affineB ?? this.affineB,
    );
  }
}

class CustomCipherScreen extends StatefulWidget {
  const CustomCipherScreen({super.key});

  @override
  State<CustomCipherScreen> createState() => _CustomCipherScreenState();
}

class _CustomCipherScreenState extends State<CustomCipherScreen> {
  final _nameController = TextEditingController();
  Alphabet _base = BuiltinAlphabets.russian;
  final List<_RuleStep> _steps = [];
  int _nextId = 1;
  String _preview = '';
  String _encExample = '';
  String _decExample = '';

  @override
  void initState() {
    super.initState();
    _addStep();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addStep() {
    setState(() => _steps.add(_RuleStep(id: _nextId++)));
    _rebuildPreview();
  }

  void _removeStep(_RuleStep step) {
    setState(() => _steps.remove(step));
    _rebuildPreview();
  }

  void _moveStep(_RuleStep step, int dir) {
    final i = _steps.indexOf(step);
    final j = i + dir;
    if (i < 0 || j < 0 || j >= _steps.length) return;
    setState(() {
      final tmp = _steps[i];
      _steps[i] = _steps[j];
      _steps[j] = tmp;
    });
    _rebuildPreview();
  }

  void _updateStep(_RuleStep step, _RuleStep next) {
    final i = _steps.indexOf(step);
    if (i < 0) return;
    setState(() => _steps[i] = next);
    _rebuildPreview();
  }

  List<String> _keywordAlphabet(Alphabet base, String keyword) {
    final used = <String>{};
    final result = <String>[];
    for (final r in keyword.toLowerCase().runes) {
      final c = String.fromCharCode(r);
      if (!base.containsChar(c)) continue;
      if (used.add(c)) result.add(c);
    }
    for (final c in base.chars) {
      if (used.add(c)) result.add(c);
    }
    return result;
  }

  List<String> _customAlphabet(Alphabet base, String custom) {
    final used = <String>{};
    final result = <String>[];
    for (final r in custom.toLowerCase().runes) {
      final c = String.fromCharCode(r);
      if (!base.containsChar(c)) continue;
      if (used.add(c)) result.add(c);
    }
    return result;
  }

  /// Applies the steps in order to compose the final cipher alphabet.
  String _compose(Alphabet base, List<_RuleStep> steps) {
    final n = base.length;
    if (n == 0) return '';
    var cur = List<String>.from(base.chars);
    for (final s in steps) {
      final mapped = List<String>.generate(n, (i) {
        final idx = base.indexOfChar(cur[i]);
        switch (s.type) {
          case _RuleType.shift:
            return base.charAt(idx + s.shift);
          case _RuleType.mirror:
            return base.charAt(n - 1 - idx);
          case _RuleType.keyword:
            return _keywordAlphabet(base, s.keyword)[idx];
          case _RuleType.custom:
            return _customAlphabet(base, s.custom)[idx];
          case _RuleType.affine:
            var a = s.affineA;
            if (a == 0 || gcd(mod(a, n), n) != 1) a = 1;
            return base.charAt((a * idx + s.affineB) % n);
          case _RuleType.rotHalf:
            return base.charAt((idx + n ~/ 2) % n);
          case _RuleType.oddEven:
            final order = <int>[
              for (var j = 0; j < n; j += 2) j,
              for (var j = 1; j < n; j += 2) j,
            ];
            return base.charAt(order[idx]);
        }
      });
      cur = mapped;
    }
    return cur.join();
  }

  bool _validateCustomSteps() {
    for (final s in _steps) {
      if (s.type != _RuleType.custom) continue;
      final clean = _customAlphabet(_base, s.custom);
      if (clean.length != _base.length) return false;
    }
    return true;
  }

  String _exampleWord = 'привет';

  void _rebuildPreview([String? exampleWord]) {
    final example = exampleWord ?? _exampleWord;
    _exampleWord = example;
    final composed = _compose(_base, _steps);
    if (composed.isEmpty) {
      setState(() {
        _preview = '';
        _encExample = '';
        _decExample = '';
      });
      return;
    }
    final engine = CustomSubstitutionCipher(cipherLetters: composed);
    var sample = engine.filterInput(example, _base);
    if (sample.isEmpty) {
      sample = _base.lower.substring(0, _base.length < 4 ? _base.length : 4);
    }
    final enc = engine.encrypt(sample, _base);
    setState(() {
      _preview = composed;
      _encExample = enc;
      _decExample = engine.decrypt(enc, _base);
    });
  }

  Future<void> _save(AppStrings strings) async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.customCipherError)),
      );
      return;
    }
    if (_steps.isEmpty || _preview.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.customLengthError)),
      );
      return;
    }
    if (!_validateCustomSteps()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.customLengthError)),
      );
      return;
    }
    final settings = ShiferScope.settingsOf(context);
    final def = CustomCipherDef(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      baseAlphabetId: _base.id,
      cipherLetters: _preview,
      description: strings.customCipherSavedDesc,
    );
    await settings.addCustomCipher(def);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.customCipherSaved)),
    );
    _nameController.clear();
    _rebuildPreview();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ShiferScope.settingsOf(context);
    final strings = AppStrings(settings.localeCode);
    if (_exampleWord != strings.exampleWord) {
      final target = strings.exampleWord;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _exampleWord != target) {
          _rebuildPreview(target);
        }
      });
    }

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Text(
                strings.customStudioTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                strings.customStudioSubtitle,
                style: TextStyle(color: ShiferTheme.muted, height: 1.35),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ShiferTheme.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: ShiferTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration:
                          InputDecoration(labelText: strings.customCipherName),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _base.id,
                      decoration:
                          InputDecoration(labelText: strings.alphabetLabel),
                      items: [
                        for (final a in settings.allAlphabets)
                          DropdownMenuItem(
                            value: a.id,
                            child: Text(
                              a.isCustom ? a.nameKey : strings.t(a.nameKey),
                            ),
                          ),
                      ],
                      onChanged: (id) {
                        if (id == null) return;
                        setState(() {
                          _base = settings.findAlphabet(id) ?? _base;
                        });
                        _rebuildPreview();
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            strings.constructorSteps,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _addStep,
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(strings.constructorAddStep),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (_steps.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          strings.constructorNoSteps,
                          style: TextStyle(color: ShiferTheme.muted),
                        ),
                      )
                    else
                      ..._steps.asMap().entries.map((entry) {
                        final i = entry.key;
                        final step = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _StepCard(
                            key: ValueKey(step.id),
                            step: step,
                            index: i,
                            total: _steps.length,
                            strings: strings,
                            onChanged: (next) => _updateStep(step, next),
                            onRemove: () => _removeStep(step),
                            onMoveUp: () => _moveStep(step, -1),
                            onMoveDown: () => _moveStep(step, 1),
                          ),
                        );
                      }),
                    const SizedBox(height: 12),
                    Text(
                      strings.customCipherPreview,
                      style: TextStyle(
                        color: ShiferTheme.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ShiferTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ShiferTheme.border),
                      ),
                      child: Text(
                        _preview.isEmpty ? '—' : _preview,
                        style: const TextStyle(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (_encExample.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        strings.constructorExample,
                        style: TextStyle(
                          color: ShiferTheme.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ShiferTheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: ShiferTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _encExample,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${strings.example}: $_decExample',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                                color: ShiferTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () => _save(strings),
                      icon: const Icon(Icons.save_outlined),
                      label: Text(strings.save),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                strings.customCipherList,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              if (settings.customCiphers.isEmpty)
                Text(
                  strings.customCipherEmpty,
                  style: TextStyle(color: ShiferTheme.muted),
                )
              else
                ...settings.customCiphers.map((c) {
                  final info = settings.allCiphers.firstWhere(
                    (x) =>
                        x.isUserDefined &&
                        x.nameKey == c.name &&
                        x.customCipherLetters == c.cipherLetters,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: ShiferTheme.border),
                      ),
                      tileColor: ShiferTheme.card,
                      title: Text(c.name),
                      subtitle: Text(
                        c.cipherLetters,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: ShiferTheme.danger),
                        onPressed: () => settings.removeCustomCipher(c.id),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CipherScreen(info: info),
                          ),
                        );
                      },
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatefulWidget {
  final _RuleStep step;
  final int index;
  final int total;
  final AppStrings strings;
  final ValueChanged<_RuleStep> onChanged;
  final VoidCallback onRemove;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  const _StepCard({
    super.key,
    required this.step,
    required this.index,
    required this.total,
    required this.strings,
    required this.onChanged,
    required this.onRemove,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> {
  late final TextEditingController _shiftController;
  late final TextEditingController _keywordController;
  late final TextEditingController _customController;
  late final TextEditingController _affineAController;
  late final TextEditingController _affineBController;

  _RuleType get _type => widget.step.type;

  @override
  void initState() {
    super.initState();
    _shiftController = TextEditingController(text: '${widget.step.shift}');
    _keywordController = TextEditingController(text: widget.step.keyword);
    _customController = TextEditingController(text: widget.step.custom);
    _affineAController = TextEditingController(text: '${widget.step.affineA}');
    _affineBController = TextEditingController(text: '${widget.step.affineB}');
  }

  @override
  void didUpdateWidget(covariant _StepCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.type != widget.step.type) {
      _shiftController.text = '${widget.step.shift}';
      _keywordController.text = widget.step.keyword;
      _customController.text = widget.step.custom;
      _affineAController.text = '${widget.step.affineA}';
      _affineBController.text = '${widget.step.affineB}';
    }
  }

  @override
  void dispose() {
    _shiftController.dispose();
    _keywordController.dispose();
    _customController.dispose();
    _affineAController.dispose();
    _affineBController.dispose();
    super.dispose();
  }

  void _setType(_RuleType type) {
    widget.onChanged(widget.step.copyWith(type: type));
  }

  List<Widget> _paramFields() {
    switch (_type) {
      case _RuleType.shift:
        return [
          Expanded(
            child: TextField(
              controller: _shiftController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'-?\d*')),
              ],
              decoration: InputDecoration(
                labelText: widget.strings.shiftAmount,
                isDense: true,
              ),
              onChanged: (v) => widget.onChanged(
                widget.step.copyWith(shift: int.tryParse(v) ?? 0),
              ),
            ),
          ),
        ];
      case _RuleType.keyword:
        return [
          Expanded(
            child: TextField(
              controller: _keywordController,
              decoration: InputDecoration(
                labelText: widget.strings.keyword,
                isDense: true,
              ),
              onChanged: (v) =>
                  widget.onChanged(widget.step.copyWith(keyword: v)),
            ),
          ),
        ];
      case _RuleType.custom:
        return [
          Expanded(
            child: TextField(
              controller: _customController,
              decoration: InputDecoration(
                labelText: widget.strings.customLettersLabel,
                helperText: widget.strings.customLettersHelp,
                isDense: true,
              ),
              onChanged: (v) =>
                  widget.onChanged(widget.step.copyWith(custom: v)),
            ),
          ),
        ];
      case _RuleType.affine:
        return [
          Expanded(
            child: TextField(
              controller: _affineAController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'-?\d*')),
              ],
              decoration: InputDecoration(
                labelText: widget.strings.affineA,
                isDense: true,
              ),
              onChanged: (v) => widget.onChanged(
                widget.step.copyWith(affineA: int.tryParse(v) ?? 1),
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
                labelText: widget.strings.affineB,
                isDense: true,
              ),
              onChanged: (v) => widget.onChanged(
                widget.step.copyWith(affineB: int.tryParse(v) ?? 0),
              ),
            ),
          ),
        ];
      case _RuleType.mirror:
      case _RuleType.rotHalf:
      case _RuleType.oddEven:
        return [
          Expanded(
            child: Text(
              widget.strings.constructorNoParams,
              style: TextStyle(color: ShiferTheme.muted, fontSize: 13),
            ),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ShiferTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ShiferTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                child: DropdownButtonFormField<_RuleType>(
                  initialValue: _type,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: widget.strings.constructorRule,
                    isDense: true,
                  ),
                  items: [
                    for (final type in _RuleType.values)
                      DropdownMenuItem(
                        value: type,
                        child: Text(widget.strings.t(_ruleKeyOf(type))),
                      ),
                  ],
                  onChanged: (type) {
                    if (type == null) return;
                    _setType(type);
                  },
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: widget.strings.constructorMoveUp,
                onPressed:
                    widget.index == 0 ? null : widget.onMoveUp,
                icon: const Icon(Icons.arrow_upward, size: 18),
              ),
              IconButton(
                tooltip: widget.strings.constructorMoveDown,
                onPressed: widget.index == widget.total - 1
                    ? null
                    : widget.onMoveDown,
                icon: const Icon(Icons.arrow_downward, size: 18),
              ),
              IconButton(
                tooltip: widget.strings.delete,
                onPressed: widget.onRemove,
                icon: Icon(Icons.close, size: 20, color: ShiferTheme.danger),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(children: _paramFields()),
        ],
      ),
    );
  }

  static String _ruleKeyOf(_RuleType type) {
    switch (type) {
      case _RuleType.shift:
        return 'ruleShift';
      case _RuleType.mirror:
        return 'ruleMirror';
      case _RuleType.keyword:
        return 'ruleKeyword';
      case _RuleType.custom:
        return 'ruleCustom';
      case _RuleType.affine:
        return 'ruleAffine';
      case _RuleType.rotHalf:
        return 'ruleRotHalf';
      case _RuleType.oddEven:
        return 'ruleOddEven';
    }
  }
}