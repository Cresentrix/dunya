import 'package:flutter/material.dart';

import 'adaptive_screen.dart';
import 'bottom_sheet_screen.dart';
import 'dialog_screen.dart';
import 'dropdown_screen.dart';
import 'dial_code_screen.dart';
import 'search_screen.dart';
import 'theme_screen.dart';
import 'flag_gallery_screen.dart';
import 'phase3_demo_screen.dart';
import 'real_world_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const HomeScreen({required this.onToggleTheme, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duniya'),
        actions: [
          IconButton(
            onPressed: onToggleTheme,
            icon: Icon(
              Theme.of(context).brightness == Brightness.light
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
            ),
          ),
        ],
      ),
      body: ListView(
        children: const [
          _DemoTile(
            icon: Icons.expand_circle_down_outlined,
            title: 'Bottom Sheet',
            description: 'Modal bottom sheet — drag handle, search, 75% height',
          ),
          _DemoTile(
            icon: Icons.picture_in_picture_outlined,
            title: 'Dialog',
            description: 'Centered dialog — search, close, cancel button',
          ),
          _DemoTile(
            icon: Icons.arrow_drop_down_circle_outlined,
            title: 'Dropdown',
            description: 'Inline overlay — 320dp, tap outside to dismiss',
          ),
          _DemoTile(
            icon: Icons.phone_outlined,
            title: 'Dial Code Field',
            description: 'Phone input with flag, dial code, and picker',
          ),
          _DemoTile(
            icon: Icons.search_outlined,
            title: 'Search',
            description: 'Ranked search across name, code, dial, native',
          ),
          _DemoTile(
            icon: Icons.palette_outlined,
            title: 'Theme Customizer',
            description: 'Live DunyaPickerTheme token overrides',
          ),
          _DemoTile(
            icon: Icons.auto_awesome_outlined,
            title: 'Adaptive Mode',
            description:
                'Cupertino on iOS/macOS, Material elsewhere. Glass effect toggle.',
          ),
          _DemoTile(
            icon: Icons.new_releases_outlined,
            title: 'Phase 3 Features',
            description:
                'Favorites, phone validation, scroll-to-selected',
          ),
          _DemoTile(
            icon: Icons.business_outlined,
            title: 'Real World',
            description: 'Contact form with phone field — real app scenario',
          ),
          _DemoTile(
            icon: Icons.flag_outlined,
            title: 'Flag Gallery',
            description: 'All 250 SVG flags with FlagWidget',
          ),
        ],
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _DemoTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  Widget? _buildScreen() {
    switch (title) {
      case 'Bottom Sheet':
        return const BottomSheetScreen();
      case 'Dialog':
        return const DialogScreen();
      case 'Dropdown':
        return const DropdownScreen();
      case 'Dial Code Field':
        return const DialCodeScreen();
      case 'Search':
        return const SearchScreen();
      case 'Theme Customizer':
        return const ThemeScreen();
      case 'Adaptive Mode':
        return const AdaptiveScreen();
      case 'Phase 3 Features':
        return const Phase3DemoScreen();
      case 'Real World':
        return const RealWorldScreen();
      case 'Flag Gallery':
        return const FlagGalleryScreen();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(description),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        final screen = _buildScreen();
        if (screen != null) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => screen),
          );
        }
      },
    );
  }
}
