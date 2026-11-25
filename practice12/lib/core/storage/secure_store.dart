import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  const SecureStore();
  static const _key = 'auth_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Future<void> saveToken(String token) =>
      _storage.write(key: _key, value: token);

  Future<String?> readToken() async {
    try {
      return await _storage.read(key: _key);
    } on PlatformException {
      await _storage.delete(key: _key);
      return null;
    }
  }

  Future<void> clear() => _storage.delete(key: _key);
}
