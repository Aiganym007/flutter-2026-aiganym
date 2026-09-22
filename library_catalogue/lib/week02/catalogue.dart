import 'models.dart';

class Library {
  final List<LibraryItem> items = [];
  void add(LibraryItem item) => items.add(item);

  // Null safety
  Book? findByTitle(String title) {
    for (final item in items) {
      if (item is Book && item.title == title) return item;
    }
    return null;
  }
  String countryOf(String title) => findByTitle(title)?.author.country ?? 'unknown';
  late final DateTime openedAt;
  void open() => openedAt = DateTime.now();
  String? _cachedReport;
  List<Book> get _books => items.whereType<Book>().toList();


  // Level 4: Collections
  Iterable<String> get allTitles => items.map((item) => item.title);
  Iterable<Book> get booksAfter2010 => _books.where((book) => book.year > 2010);
  double get averagePages =>
  _books.isEmpty ? 0
      : _books.fold<int>(0, (sum, book) => sum + book.pages) / _books.length;

  Map<String, int> get bookCountByAuthor => _books.fold<Map<String, int>>(
    {},
        (counts, book) =>
    counts..update(book.author.name, (n) => n + 1, ifAbsent: () => 1),
  );

  Set<String> get distinctAuthors => _books.map((book) => book.author.name).toSet();
  Set<Genre> get genresPresent => _books.map((book) => book.genre).toSet();

  String buildReport() {
    return _cachedReport ??= [
      'CATALOGUE',
      for (final book in _books) '${book.title} (${book.year})',
      ...distinctAuthors,
      if (_books.any((book) => book.pages == 0)) '(incomplete data)',
    ].join('\n');
  }
}