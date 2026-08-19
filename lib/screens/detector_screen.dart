import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/alphabet.dart';
import '../services/cipher_detector.dart';
import '../theme/shifer_theme.dart';
import '../widgets/shifer_scope.dart';
import 'cipher_screen.dart';

class DetectorScreen extends StatefulWidget {
  const DetectorScreen({super.key});

  @override
  State<DetectorScreen> createState() => _DetectorScreenState();
}

class _DetectorScreenState extends State<DetectorScreen> {
  final _controller = TextEditingController();
  Alphabet _alphabet = BuiltinAlphabets.russian;
  List<DetectionHit> _hits = [];
  bool _running = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _run(AppStrings strings) async {
    setState(() => _running = true);
    await Future<void>.delayed(Duration.zero);
    final hits = CipherDetector().analyze(
      _controller.text,
      alphabet: _alphabet,
      isRu: strings.isRu,
    );
    if (!mounted) return;
    setState(() {
      _hits = hits;
      _running = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ShiferScope.settingsOf(context);
    final strings = AppStrings(settings.localeCode);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.detectorTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  strings.detectorSubtitle,
                  style: TextStyle(color: ShiferTheme.muted, height: 1.35),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _alphabet.id,
                  decoration: InputDecoration(labelText: strings.alphabetLabel),
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
                      _alphabet = settings.findAlphabet(id) ?? _alphabet;
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _controller,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: strings.detectorHint,
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _running ? null : () => _run(strings),
                        icon: _running
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.radar),
                        label: Text(strings.detectorAnalyze),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  strings.detectorNote,
                  style: TextStyle(fontSize: 12, color: ShiferTheme.muted),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _hits.isEmpty
                      ? Center(
                          child: Text(
                            strings.detectorEmpty,
                            style: TextStyle(color: ShiferTheme.muted),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _hits.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final hit = _hits[i];
                            final name = hit.info.isUserDefined
                                ? hit.info.nameKey
                                : strings.t(hit.info.nameKey);
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: Duration(milliseconds: 280 + i * 40),
                              curve: Curves.easeOutCubic,
                              builder: (context, t, child) => Opacity(
                                opacity: t,
                                child: Transform.translate(
                                  offset: Offset(0, 12 * (1 - t)),
                                  child: child,
                                ),
                              ),
                              child: Material(
                                color: ShiferTheme.card,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CipherScreen(info: hit.info),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: i == 0
                                            ? ShiferTheme.primary
                                                .withValues(alpha: 0.55)
                                            : ShiferTheme.border,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '${(hit.score * 100).clamp(0, 99).toStringAsFixed(0)}%',
                                              style: TextStyle(
                                                color: i == 0
                                                    ? ShiferTheme.primary
                                                    : ShiferTheme.muted,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          hit.detail,
                                          style: TextStyle(
                                            color: ShiferTheme.accent,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          hit.plaintext,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
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
