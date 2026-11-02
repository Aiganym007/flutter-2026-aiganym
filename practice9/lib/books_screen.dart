import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Book> get _visible {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return books;
    return books
        .where(
          (b) =>
              b.title.toLowerCase().contains(q) ||
              b.author.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    final visible = _visible;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _search,
          decoration: InputDecoration(
            hintText: 'Search books',
            border: InputBorder.none,
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _search.clear();
                      setState(() => _query = '');
                    },
                  ),
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
        actions: const [CartBadge()],
      ),
      body: visible.isEmpty
          ? const Center(child: Text('No books found'))
          : ListView.builder(
              itemCount: visible.length,
              itemBuilder: (_, i) =>
                  _BookRow(key: ValueKey(visible[i].title), book: visible[i]),
            ),
    );
  }
}

class _BookRow extends StatelessWidget {
  const _BookRow({super.key, required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    debugPrint('row ${book.title}');
    final inCart = context.select<Cart, bool>((c) => c.qtyOf(book) > 0);
    return ListTile(
      title: Text(book.title),
      subtitle: Text(book.author),
      trailing: inCart
          ? const Text('Added')
          : OutlinedButton(
              onPressed: () => _add(context),
              child: const Text('Add'),
            ),
    );
  }

  void _add(BuildContext context) {
    final ok = context.read<Cart>().add(book);
    if (ok) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Added'),
            duration: Duration(seconds: 1),
          ),
        );
    }
  }
}
