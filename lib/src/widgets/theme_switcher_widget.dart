import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeSwitcherWidget extends StatelessWidget {
  final bool showLabel;
  
  const ThemeSwitcherWidget({
    Key? key,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return PopupMenuButton<ThemeMode>(
          icon: Icon(
            themeProvider.isDarkMode 
                ? Icons.dark_mode 
                : Icons.light_mode,
          ),
          onSelected: (ThemeMode mode) {
            themeProvider.setThemeMode(mode);
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.system,
              child: Row(
                children: [
                  Icon(
                    Icons.settings_suggest,
                    color: themeProvider.isSystemMode 
                        ? Theme.of(context).colorScheme.primary 
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'System',
                    style: TextStyle(
                      fontWeight: themeProvider.isSystemMode 
                          ? FontWeight.w600 
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.light,
              child: Row(
                children: [
                  Icon(
                    Icons.light_mode,
                    color: themeProvider.themeMode == ThemeMode.light 
                        ? Theme.of(context).colorScheme.primary 
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Light',
                    style: TextStyle(
                      fontWeight: themeProvider.themeMode == ThemeMode.light 
                          ? FontWeight.w600 
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.dark,
              child: Row(
                children: [
                  Icon(
                    Icons.dark_mode,
                    color: themeProvider.themeMode == ThemeMode.dark 
                        ? Theme.of(context).colorScheme.primary 
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Dark',
                    style: TextStyle(
                      fontWeight: themeProvider.themeMode == ThemeMode.dark 
                          ? FontWeight.w600 
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
          tooltip: 'Change theme',
        );
      },
    );
  }
}