import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_exception.dart';
import 'new_user_screen.dart';
import 'state_views.dart';
import 'user_list.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: m.load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const NewUserScreen()),
        ),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('New user'),
      ),
      body: _body(m),
    );
  }

  Widget _body(UsersModel m) {
    if (m.loading && m.items.isEmpty) return const LoadingView();
    return switch (m.error) {
      null => UserList(m.items, onRefresh: m.load),
      NoConnectionException() => Offline(onRetry: m.load),
      NotFoundException() => const RequestError(
        title: 'Not found',
        text: 'The server does not have what we asked for.',
      ),
      UnauthorizedException() => const RequestError(
        title: 'Not signed in',
        text: 'The server refused the request (401).',
      ),
      ServerException(:final status) => ServerError(
        status: status,
        onRetry: m.load,
      ),
      BadResponseException() => const GenericError(),
    };
  }
}
