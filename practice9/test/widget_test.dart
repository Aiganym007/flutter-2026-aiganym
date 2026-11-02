import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:put_it_high/main.dart';
import 'package:put_it_high/models/book.dart';
import 'package:put_it_high/models/cart.dart';

void main() {
  group('Cart model (no widgets)', () {
    test('add refuses duplicates', () {
      final cart = Cart();
      expect(cart.add(books[0]), isTrue);
      expect(cart.add(books[0]), isFalse);
      expect(cart.count, 1);
    });

    test('total multiplies price by quantity', () {
      final cart = Cart()
        ..add(books[0])
        ..add(books[1])
        ..increment(books[1]);
      expect(cart.qtyOf(books[1]), 2);
      expect(cart.total, books[0].price + books[1].price * 2);
      expect(cart.count, 2);
    });

    test('items is unmodifiable', () {
      final cart = Cart()..add(books[0]);
      expect(() => cart.items.add(books[1]), throwsUnsupportedError);
    });

    test('every mutation notifies', () {
      final cart = Cart();
      var calls = 0;
      cart.addListener(() => calls++);
      cart.add(books[0]);
      cart.increment(books[0]);
      cart.remove(books[0]);
      cart.clear();
      expect(calls, 4);
    });
  });

  testWidgets('Add puts a book in the cart and shows the badge', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(create: (_) => Cart(), child: const Shell()),
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Add').first);
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('Added'), findsNWidgets(2));
  });
}
