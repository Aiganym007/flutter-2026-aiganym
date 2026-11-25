// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileModel extends ChangeNotifier {
  ProfileModel(this._prefs, {String? avatarPath}) : _avatarPath = avatarPath;
  final SharedPreferencesAsync _prefs;
  String? _avatarPath;
  String? get avatarPath => _avatarPath;

  Future<void> setAvatar(String path) async {
    _avatarPath = path;
    notifyListeners();
    await _prefs.setString('avatarPath', path);
  }
}
