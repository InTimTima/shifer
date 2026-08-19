import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../theme/shifer_theme.dart';
import '../widgets/shifer_scope.dart';
import 'custom_cipher_screen.dart';
import 'detector_screen.dart';
import 'home_screen.dart';
import 'mixer_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(ShiferScope.settingsOf(context).localeCode);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ShiferTheme.bg,
              Color.lerp(ShiferTheme.bg, ShiferTheme.surface, 0.45)!,
              ShiferTheme.bg,
            ],
          ),
        ),
        child: IndexedStack(
          index: _index,
          children: const [
            HomeScreen(),
            DetectorScreen(),
            CustomCipherScreen(),
            MixerScreen(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.grid_view_rounded),
            selectedIcon: const Icon(Icons.grid_view_rounded),
            label: strings.navCiphers,
          ),
          NavigationDestination(
            icon: const Icon(Icons.radar_outlined),
            selectedIcon: const Icon(Icons.radar),
            label: strings.navDetector,
          ),
          NavigationDestination(
            icon: const Icon(Icons.handyman_outlined),
            selectedIcon: const Icon(Icons.handyman),
            label: strings.navStudio,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_tree_outlined),
            selectedIcon: const Icon(Icons.account_tree),
            label: strings.navMixer,
          ),
        ],
      ),
    );
  }
}

/// Subtle top glow used on feature screens.
class AmbientGlow extends StatelessWidget {
  final Widget child;

  const AmbientGlow({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -40,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ShiferTheme.primary.withValues(alpha: 0.07),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
