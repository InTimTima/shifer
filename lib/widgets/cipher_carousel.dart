import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_strings.dart';
import '../models/alphabet.dart';
import '../models/cipher_info.dart';
import '../theme/shifer_theme.dart';
import 'cipher_card.dart';

class CipherCarousel extends StatefulWidget {
  final List<CipherInfo> ciphers;
  final AppStrings strings;
  final Alphabet demoAlphabet;
  final ValueChanged<CipherInfo> onOpen;

  const CipherCarousel({
    super.key,
    required this.ciphers,
    required this.strings,
    required this.demoAlphabet,
    required this.onOpen,
  });

  @override
  State<CipherCarousel> createState() => _CipherCarouselState();
}

class _CipherCarouselState extends State<CipherCarousel> {
  static const _loopSpan = 20000;
  PageController? _controller;
  int _logicalIndex = 0;
  int _basePage = 0;

  int get _count => widget.ciphers.length;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant CipherCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ciphers != widget.ciphers) {
      _controller?.dispose();
      _logicalIndex = 0;
      _initController();
    }
  }

  void _initController() {
    if (_count == 0) {
      _controller = null;
      return;
    }
    _basePage = (_loopSpan ~/ 2) - ((_loopSpan ~/ 2) % _count);
    _controller = PageController(
      initialPage: _basePage,
      viewportFraction: 0.86,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  int _realIndex(int page) => page % _count;

  Future<void> _animateBy(int delta) async {
    final controller = _controller;
    if (controller == null || !controller.hasClients || _count == 0) return;
    final current = controller.page?.round() ?? _basePage;
    await controller.animateToPage(
      current + delta,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || _count == 0) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _animateBy(1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _animateBy(-1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    if (_count == 0) {
      return Center(
        child: Text(
          widget.strings.noCiphersFound,
          style: TextStyle(color: ShiferTheme.muted),
        ),
      );
    }

    final controller = _controller!;

    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                _ArrowButton(
                  icon: Icons.chevron_left,
                  onPressed: () => _animateBy(-1),
                ),
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.trackpad,
                        PointerDeviceKind.stylus,
                      },
                    ),
                    child: PageView.builder(
                      controller: controller,
                      // Large virtual count for looping.
                      itemCount: _loopSpan,
                      onPageChanged: (page) {
                        setState(() => _logicalIndex = _realIndex(page));
                      },
                      itemBuilder: (context, page) {
                        final info = widget.ciphers[_realIndex(page)];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: CipherCard(
                            info: info,
                            strings: widget.strings,
                            demoAlphabet: widget.demoAlphabet,
                            onOpen: () => widget.onOpen(info),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                _ArrowButton(
                  icon: Icons.chevron_right,
                  onPressed: () => _animateBy(1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${_logicalIndex + 1} / $_count',
            style: TextStyle(
              color: ShiferTheme.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ArrowButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 32),
      color: ShiferTheme.primary,
      tooltip: null,
    );
  }
}
