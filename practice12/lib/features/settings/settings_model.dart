import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  SettingsModel(this._prefs, {required bool dark, String? city})
    : _dark = dark,
      _city = city;

  final SharedPreferencesAsync _prefs;
  bool _dark;
  String? _city;
  bool get dark => _dark;
  String? get city => _city;

  Future<void> setDark(bool v) async {
    _dark = v;
    notifyListeners();
    await _prefs.setBool('darkMode', v);
  }

  Future<void> setCity(String? c) async {
    _city = c;
    notifyListeners();
    if (c == null) {
      await _prefs.remove('cityFilter');
    } else {
      await _prefs.setString('cityFilter', c);
    }
  }
}
