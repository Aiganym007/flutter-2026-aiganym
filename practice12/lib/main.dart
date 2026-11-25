import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/api/api_client.dart';
import 'core/storage/secure_store.dart';
import 'features/auth/auth_model.dart';
import 'features/profile/profile_model.dart';
import 'features/settings/settings_model.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_cache.dart';
import 'features/users/users_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = SharedPreferencesAsync();
  final dark = await prefs.getBool('darkMode') ?? false;
  final city = await prefs.getString('cityFilter');
  final savedAvatar = await prefs.getString('avatarPath');
  final avatar = savedAvatar != null && File(savedAvatar).existsSync()
      ? savedAvatar
      : null;
  const store = SecureStore();
  final token = await store.readToken();
  final api = ApiClient(http.Client(), store);

  runApp(
    MultiProvider(
      providers: [
        Provider<SecureStore>.value(value: store),
        ChangeNotifierProvider(
          create: (_) => SettingsModel(prefs, dark: dark, city: city),
        ),
        ChangeNotifierProvider(create: (_) => AuthModel(store, token: token)),
        ChangeNotifierProvider(
          create: (_) => ProfileModel(prefs, avatarPath: avatar),
        ),
        ChangeNotifierProvider(
          create: (_) {
            final model = UsersModel(UserRepository(api, UsersCache()));
            unawaited(model.load());
            return model;
          },
        ),
      ],
      child: const App(),
    ),
  );
}
