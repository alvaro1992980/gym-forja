import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'preferences.g.dart';

/// Small per-device settings (not secrets: those go to secure storage).
class Preferences {
  Preferences([SharedPreferencesAsync? prefs])
    : _prefs = prefs ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;

  Future<bool?> getBool(String key) => _prefs.getBool(key);

  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);
}

@Riverpod(keepAlive: true)
Preferences preferences(Ref ref) => Preferences();
