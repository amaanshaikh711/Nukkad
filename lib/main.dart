import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nukkad/core/router/app_router.dart';
import 'package:nukkad/core/theme/app_theme.dart';
import 'package:nukkad/features/settings/presentation/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Hive for offline local storage
    await Hive.initFlutter();
  } catch (e) {
    if (kDebugMode) {
      print('Hive init warning: $e');
    }
  }

  runApp(
    const ProviderScope(
      child: NukkadApp(),
    ),
  );
}

class NukkadApp extends ConsumerWidget {
  const NukkadApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsNotifierProvider);

    return MaterialApp.router(
      title: 'Nukkad — Local-First Neighborhood Marketplace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsState.themeMode,
      routerConfig: appRouter,
    );
  }
}
