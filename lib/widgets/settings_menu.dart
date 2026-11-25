import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

/// Header menu: theme (system / light / dark) and, on the feed page, "Hide read stories".
class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key, this.showHideRead = false});

  final bool showHideRead;

  static const _modes = [
    (ThemeMode.system, 'Match system', Icons.brightness_auto_outlined),
    (ThemeMode.light, 'Light', Icons.light_mode_outlined),
    (ThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final scheme = Theme.of(context).colorScheme;

    return PopupMenuButton<Object>(
      tooltip: 'Settings',
      icon: const Icon(Icons.tune),
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      offset: const Offset(0, 44),
      onSelected: (value) {
        if (value is ThemeMode) {
          settings.setThemeMode(value);
        } else {
          settings.setHideRead(!settings.hideRead);
        }
      },
      itemBuilder: (_) => [
        if (showHideRead) ...[
          CheckedPopupMenuItem<Object>(
            value: 'hide-read',
            checked: settings.hideRead,
            child: const Text('Hide read stories'),
          ),
          const PopupMenuDivider(),
        ],
        for (final (mode, label, icon) in _modes)
          PopupMenuItem<Object>(
            value: mode,
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: settings.themeMode == mode
                      ? scheme.primary
                      : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(label)),
                if (settings.themeMode == mode)
                  Icon(Icons.check, size: 18, color: scheme.primary),
              ],
            ),
          ),
      ],
    );
  }
}
