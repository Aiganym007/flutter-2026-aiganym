import 'data.dart';
import 'models.dart';
import 'catalogue.dart';
import 'shelf_state.dart';

void main() {
  final library = Library();
  library.open();
  for (final raw in rawBooks) {
    library.add(Book.fromJson(raw));
  }
  library.add(const Magazine(title: 'Dart Weekly', year: 2024, issue: 12));
  library.add(const Ghost(title: 'Lost Ledger Entry', year: 1987));
  print('Library opened at: ${library.openedAt}');
  print('');
  print('All titles:');
  for (final title in library.allTitles) {
    print('  - $title');
  }
  print('');

  print('Books after 2010:');
  for (final book in library.booksAfter2010) {
    print('  - ${book.title} (${book.year})');
  }
  print('');

  print('Average page count: ${library.averagePages.toStringAsFixed(1)}');
  print('Books per author: ${library.bookCountByAuthor}');
  print('Distinct authors: ${library.distinctAuthors}');
  print('Genres present: ${library.genresPresent}');
  print('');

  print(library.buildReport());
  print('');

  print('Country of "Design Patterns": ${library.countryOf('Design Patterns')}');
  print('Country of "Nonexistent Title": ${library.countryOf('Nonexistent Title')}');
  print('');

  final firstBook = library.findByTitle('Clean Code');
  if (firstBook != null) {
    print(firstBook.borrowLabel());
  }
  print('');

  final books = rawBooks.map((json) => Book.fromJson(json)).toList();
  final stats = statsOf(books);
  print('statsOf record: count=${stats.count}, avgPages=${stats.avgPages.toStringAsFixed(1)}');
  print('');

  const ShelfState empty = Empty();
  final ShelfState ready = Ready(books);
  const ShelfState broken = Broken('a shelf bracket snapped');

  print(describe(empty));
  print(describe(ready));
  print(describe(broken));
}