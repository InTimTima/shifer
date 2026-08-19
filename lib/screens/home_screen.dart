import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/alphabet.dart';
import '../models/cipher_info.dart';
import '../theme/shifer_theme.dart';
import '../widgets/cipher_carousel.dart';
import '../widgets/shifer_scope.dart';
import '../widgets/wavy_logo.dart';
import 'cipher_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  CipherCategory? _category;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CipherInfo> get _filtered {
    final q = _query.trim().toLowerCase();
    final settings = ShiferScope.settingsOf(context);
    final strings = AppStrings(settings.localeCode);

    final all = settings.allCiphers;
    return all.where((c) {
      if (_category != null && c.category != _category) return false;
      if (q.isEmpty) return true;
      final name =
          (c.isUserDefined ? c.nameKey : strings.t(c.nameKey)).toLowerCase();
      final desc = strings.t(c.descriptionKey).toLowerCase();
      return name.contains(q) || desc.contains(q);
    }).toList();
  }

  void _openCipher(CipherInfo info) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CipherScreen(info: info)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ShiferScope.settingsOf(context);
    final strings = AppStrings(settings.localeCode);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 800;
    final filtered = _filtered;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 32 : 16,
                vertical: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(strings: strings, compact: !isWide),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: strings.searchCipher,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _CategoryChip(
                          label: strings.allCategories,
                          selected: _category == null,
                          onTap: () => setState(() => _category = null),
                        ),
                        _CategoryChip(
                          label: strings.categoryClassic,
                          selected: _category == CipherCategory.classic,
                          onTap: () => setState(
                            () => _category = CipherCategory.classic,
                          ),
                        ),
                        _CategoryChip(
                          label: strings.categoryMono,
                          selected: _category == CipherCategory.monoalphabetic,
                          onTap: () => setState(
                            () => _category = CipherCategory.monoalphabetic,
                          ),
                        ),
                        _CategoryChip(
                          label: strings.categoryPoly,
                          selected: _category == CipherCategory.polyalphabetic,
                          onTap: () => setState(
                            () => _category = CipherCategory.polyalphabetic,
                          ),
                        ),
                        _CategoryChip(
                          label: strings.categoryTransposition,
                          selected: _category == CipherCategory.transposition,
                          onTap: () => setState(
                            () => _category = CipherCategory.transposition,
                          ),
                        ),
                        _CategoryChip(
                          label: strings.categoryEncoding,
                          selected: _category == CipherCategory.encoding,
                          onTap: () => setState(
                            () => _category = CipherCategory.encoding,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: CipherCarousel(
                      key: ValueKey(
                        '${_category?.name ?? 'all'}|$_query|${filtered.map((e) => e.kind.name).join(',')}',
                      ),
                      ciphers: filtered,
                      strings: strings,
                      demoAlphabet: strings.isRu
                          ? BuiltinAlphabets.russian
                          : BuiltinAlphabets.english,
                      onOpen: _openCipher,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: ShiferTheme.primary.withValues(alpha: 0.18),
        labelStyle: TextStyle(
          color: selected ? ShiferTheme.primary : ShiferTheme.text,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppStrings strings;
  final bool compact;

  const _Header({required this.strings, required this.compact});

  @override
  Widget build(BuildContext context) {
    final settings = ShiferScope.settingsOf(context);
    final logoSize = compact ? 44.0 : 72.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(logoSize * 0.22),
                  boxShadow: [
                    BoxShadow(
                      color: ShiferTheme.primary.withValues(alpha: 0.28),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: WavyShiferLogo(size: logoSize),
              ),
              SizedBox(width: compact ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: compact ? 4 : 8),
                    Text(
                      strings.appName,
                      style: TextStyle(
                        fontSize: compact ? 24 : 34,
                        fontWeight: FontWeight.w800,
                        color: ShiferTheme.text,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      strings.appTagline,
                      style: TextStyle(
                        fontSize: compact ? 12 : 14,
                        height: 1.3,
                        color: ShiferTheme.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          children: [
            IconButton(
              tooltip: settings.localeCode == 'ru' ? 'English' : 'Русский',
              onPressed: () => settings.setLocale(
                settings.localeCode == 'ru' ? 'en' : 'ru',
              ),
              icon: const Icon(Icons.language),
              color: ShiferTheme.primary,
            ),
            IconButton(
              tooltip: strings.themeToggle,
              onPressed: () => settings.setBrightness(
                settings.isDark ? Brightness.light : Brightness.dark,
              ),
              icon: Icon(
                settings.isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              color: ShiferTheme.primary,
            ),
          ],
        ),
      ],
    );
  }
}
