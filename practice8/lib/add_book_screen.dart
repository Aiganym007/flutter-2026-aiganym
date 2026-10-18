import 'package:flutter/material.dart';
import 'models/book.dart';
class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _pages = TextEditingController();
  final _year = TextEditingController();

  @override
  void dispose() {
    for (final c in [_title, _author, _pages, _year]) {
      c.dispose();
    }
    super.dispose();
  }

  void _unfocus(PointerDownEvent _) =>
      FocusManager.instance.primaryFocus?.unfocus();

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final book = Book(
      title: _title.text.trim(),
      author: _author.text.trim(),
      pages: int.parse(_pages.text.trim()),
      year: int.tryParse(_year.text.trim()),
    );
    Navigator.of(context).pop(book);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Add book')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _title,
              textInputAction: TextInputAction.next,
              onTapOutside: _unfocus,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
              (v ?? '').trim().length < 2 ? 'Title is too short' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _author,
              textInputAction: TextInputAction.next,
              onTapOutside: _unfocus,
              decoration: const InputDecoration(
                labelText: 'Author',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
              (v ?? '').trim().isEmpty ? 'Author is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pages,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              onTapOutside: _unfocus,
              decoration: const InputDecoration(
                labelText: 'Pages',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                if (n == null || n <= 0) return 'A whole number above 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _year,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
              onTapOutside: _unfocus,
              decoration: const InputDecoration(
                labelText: 'Year (optional)',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return null;
                final n = int.tryParse(s);
                final now = DateTime.now().year;
                if (n == null || n < 1450 || n > now) {
                  return 'A year between 1450 and $now';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    ),
  );
}