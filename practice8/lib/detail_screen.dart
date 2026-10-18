import 'package:flutter/material.dart';
import 'models/book.dart';
enum BookAction { toggleRead, delete }
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.book});
  final Book book;
  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete '${book.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!context.mounted) return;
    Navigator.of(context).pop(BookAction.delete);
  }

  Widget _field(String label, String value) =>
      ListTile(title: Text(value), subtitle: Text(label));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Book details')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field('Title', book.title),
          _field('Author', book.author),
          _field('Pages', '${book.pages}'),
          _field('Year', book.year?.toString() ?? 'Year unknown'),
          _field('Status', book.read ? 'Read' : 'Unread'),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(BookAction.toggleRead),
            child: Text(book.read ? 'Mark as unread' : 'Mark as read'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _confirmDelete(context),
            child: const Text('Delete'),
          ),
        ],
      ),
    ),
  );
}