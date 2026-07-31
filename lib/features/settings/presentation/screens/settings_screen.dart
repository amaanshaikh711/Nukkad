import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nukkad/core/constants/app_constants.dart';
import 'package:nukkad/features/settings/presentation/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settingsState = ref.watch(settingsNotifierProvider);
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // Appearance Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Appearance',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          // Theme Selector Tile
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('App Theme'),
            subtitle: Text(
              settingsState.themeMode == ThemeMode.system
                  ? 'System Default'
                  : settingsState.themeMode == ThemeMode.dark
                      ? 'Dark Mode'
                      : 'Light Mode',
            ),
            trailing: DropdownButton<ThemeMode>(
              value: settingsState.themeMode,
              onChanged: (mode) {
                if (mode != null) settingsNotifier.setThemeMode(mode);
              },
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark'),
                ),
              ],
            ),
          ),

          const Divider(),

          // Privacy & Security Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Privacy & Security',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.security_outlined, color: Colors.green),
            title: const Text('Local-First & Offline Privacy'),
            subtitle: const Text(
              'All data stays 100% on your device. No backend servers, cloud sync, or exact address tracking.',
            ),
          ),

          const Divider(),

          // Data Management Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Data Management',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          // Reset Local Data Tile
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
            title: const Text(
              'Reset Local Data',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Clear local Hive storage and re-seed default demo items.'),
            onTap: () {
              _showResetConfirmationDialog(context, settingsNotifier);
            },
          ),

          const Divider(),

          // About Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'About Nukkad',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(AppConstants.appName),
            subtitle: const Text('Version 1.0.0 (Mobile Architecture Lab 1)'),
          ),

          ListTile(
            leading: const Icon(Icons.psychology_outlined),
            title: const Text('AI Isolation Architecture'),
            subtitle: const Text('Rule-based offline FallbackLocalAiService active.'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmationDialog(
      BuildContext context, SettingsNotifier settingsNotifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Reset Local Data?'),
          ],
        ),
        content: const Text(
          'This action will clear all user-created listings from local Hive storage and re-initialize demo listings. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await settingsNotifier.resetAllData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Local Hive storage reset and re-seeded successfully!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Reset Data'),
          ),
        ],
      ),
    );
  }
}
