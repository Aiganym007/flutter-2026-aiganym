import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/storage/secure_store.dart';
import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});
  final User user;

  Future<void> _open(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await launchUrl(uri);
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No app can open this')),
      );
    }
  }

  Future<void> _copyToken(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final store = context.read<SecureStore>();
    final token = await store.readToken();
    if (token == null) {
      messenger.showSnackBar(const SnackBar(content: Text('No token')));
      return;
    }
    await Clipboard.setData(ClipboardData(text: token));
    messenger.showSnackBar(const SnackBar(content: Text('Token copied')));
  }

  @override
  Widget build(BuildContext context) {
    final a = user.address;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: Text(user.email),
            subtitle: const Text('Email'),
            onTap: () =>
                _open(context, Uri(scheme: 'mailto', path: user.email)),
          ),
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: Text(user.phone),
            subtitle: const Text('Phone'),
            onTap: () =>
                _open(context, Uri(scheme: 'tel', path: user.phoneDigits)),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(user.website),
            subtitle: const Text('Website'),
            onTap: () => _open(context, Uri.parse('https://${user.website}')),
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text('${a.street}, ${a.suite}'),
            subtitle: Text('${a.city}, ${a.zipcode}'),
          ),
          if (kDebugMode)
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () => _copyToken(context),
                icon: const Icon(Icons.key),
                label: const Text('Copy token to clipboard'),
              ),
            ),
        ],
      ),
    );
  }
}
