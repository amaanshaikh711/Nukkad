import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nukkad/core/constants/app_constants.dart';
import 'package:nukkad/features/listing/presentation/providers/listing_providers.dart';

class SettingsState {
  final ThemeMode themeMode;
  final bool isResetting;

  SettingsState({
    required this.themeMode,
    this.isResetting = false,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? isResetting,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      isResetting: isResetting ?? this.isResetting,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Ref _ref;

  SettingsNotifier(this._ref)
      : super(SettingsState(themeMode: ThemeMode.light)) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final box = await Hive.openBox(AppConstants.settingsBoxName);
      final themeIndex = box.get('themeMode', defaultValue: ThemeMode.light.index) as int;
      if (themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
        state = state.copyWith(themeMode: ThemeMode.values[themeIndex]);
      }
    } catch (e) {
      // Safe fallback if Hive encounters storage restrictions
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    try {
      final box = await Hive.openBox(AppConstants.settingsBoxName);
      await box.put('themeMode', mode.index);
    } catch (_) {}
  }

  Future<void> resetAllData() async {
    state = state.copyWith(isResetting: true);
    final repo = _ref.read(listingRepositoryProvider);
    await repo.resetAllData();
    await _ref.read(listingListNotifierProvider.notifier).loadListings();
    state = state.copyWith(isResetting: false);
  }
}

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref);
});
