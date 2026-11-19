import 'package:flutter/material.dart';

import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({required this.user, super.key});
  final User user;

  @override
  Widget build(BuildContext context) {
    final address = user.address;
    final website = user.website;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          _Section('Account'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(user.name),
            subtitle: Text('@${user.username}  ·  id ${user.id}'),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: Text(user.email),
          ),
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: Text(user.phone),
            subtitle: Text(user.phoneDigits),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.public),
            title: Text(website ?? 'No website'),
            onTap: website == null ? null : () {},
          ),
          _Section('Address'),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: Text('${address.street}, ${address.suite}'),
            subtitle: Text('${address.city}, ${address.zipcode}'),
          ),
          ListTile(
            leading: const Icon(Icons.place_outlined),
            title: Text('${address.geo.lat}, ${address.geo.lng}'),
            subtitle: const Text('lat, lng'),
          ),
          _Section('Company'),
          ListTile(
            leading: const Icon(Icons.business_outlined),
            title: Text(user.company.name),
            subtitle: Text(user.company.catchPhrase),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
