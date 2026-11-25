import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_model.dart';
import '../settings/settings_screen.dart';
import 'user.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UsersModel>();
    final city = context.select<SettingsModel, String?>((s) => s.city);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: switch (model.state) {
        UsersLoading() => const Center(child: CircularProgressIndicator()),
        UsersFailed(:final error) => _ErrorView(
          error: error,
          onRetry: model.load,
        ),
        UsersLoaded(:final users) => _UsersList(
          users: users,
          city: city,
          fromCache: model.fromCache,
          onRetry: model.load,
        ),
      },
    );
  }
}

class _UsersList extends StatelessWidget {
  const _UsersList({
    required this.users,
    required this.city,
    required this.fromCache,
    required this.onRetry,
  });

  final List<User> users;
  final String? city;
  final bool fromCache;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final shown = [
      for (final u in users)
        if (city == null || u.address.city == city) u,
    ];

    return Column(
      children: [
        if (fromCache)
          MaterialBanner(
            leading: const Icon(Icons.cloud_off),
            content: const Text('Saved data · no connection'),
            actions: [
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        Expanded(
          child: shown.isEmpty
              ? const Center(child: Text('No users in this city'))
              : ListView.separated(
                  itemCount: shown.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final u = shown[i];
                    return ListTile(
                      leading: CircleAvatar(child: Text(u.name[0])),
                      title: Text(u.name),
                      subtitle: Text('${u.email} · ${u.address.city}'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => UserDetailScreen(user: u),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final ApiException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final (icon, title) = switch (error) {
      NoConnectionException() => (Icons.wifi_off, 'Offline'),
      RequestTimeoutException() => (Icons.hourglass_disabled, 'No answer'),
      HttpStatusException(:final statusCode) => (
        Icons.cloud_off,
        'Server error $statusCode',
      ),
      BadResponseException() => (Icons.error_outline, 'Unexpected answer'),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              error is NoConnectionException
                  ? 'No saved data yet. Connect to the internet and try again.'
                  : error.message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
