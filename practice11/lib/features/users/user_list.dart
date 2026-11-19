import 'package:flutter/material.dart';
import 'user.dart';
import 'user_detail_screen.dart';

class UserList extends StatelessWidget {
  const UserList(this.users, {required this.onRefresh, super.key});
  final List<User> users;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: users.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(user.name.isEmpty ? '?' : user.name[0]),
            ),
            title: Text(user.name),
            subtitle: Text('${user.email}\n${user.address.city}'),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => UserDetailScreen(user: user),
              ),
            ),
          );
        },
      ),
    );
  }
}
