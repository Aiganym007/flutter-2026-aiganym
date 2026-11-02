# Practice 9 — Put It High, Subscribe Low

Shop app (Books screen + Cart screen) built twice: first with state lifted
into `Shell` above `MaterialApp` (commit `lifted`), then with a `Cart`
`ChangeNotifier` and `provider` (final app).

## Level 1 — what lifting costs

**The designer asks for the total price in the badge.** With lifted state the
total has to travel from the owner down to the badge by hand:

`Shell (computes _total) → BooksScreen(total) → AppBar → actions → CartBadge(total)`

- Constructors touched: **2** — `BooksScreen` (new `total`) and `CartBadge`
  (new `total`).
- Files touched: **3** — `main.dart` (new `_total` getter + passing it),
  `books_screen.dart`, `cart_badge.dart`.
- `BooksScreen` does not even use `total` itself — it only carries it for its
  child. That is the price of "parameters down".

**Rebuild count after ONE tap on Add (Level 1):**

- `BooksScreen build` ×1 + `row …` ×6 (one per book) = **7 lines** in the
  console. `setState` in `Shell` marks everything under it dirty, although
  only one button changed.

## Level 3 — the two errors

**Loud one** (`context.watch<Cart>().add(b)` inside `onPressed`):

```
Tried to listen to a value exposed with provider, from outside of the widget tree.
```

Provider names the fix: do not subscribe in a callback — use
`context.read<Cart>()` (i.e. `Provider.of<Cart>(context, listen: false)`).

**Silent one** (`context.read<Cart>().count` inside the badge's `build`):

No error, no red line, the app compiles and runs — but the badge is frozen at
**0 forever**, because the widget never said "I depend on the cart", so
nobody rebuilds it. Rule: `watch`/`select` are verbs of `build`, `read` is a
verb of `onPressed`.

## Level 4 — measuring the badge

Cart screen, pressing **+** on a row 3 times (the number of distinct books
does not change). `debugPrint('badge build')` in `CartBadge.build`:

| Badge subscription                          | `badge build` lines after 3 × "+" |
| ------------------------------------------- | --------------------------------- |
| `context.watch<Cart>().count`               | **3**                             |
| `context.select<Cart, int>((c) => c.count)` | **0**                             |

With `select`, removing a book prints **1** line (the count changed 2 → 1).
Same model, same taps, one line changed in one widget.

Experiment: `context.watch<Cart>()` placed into `BooksScreen.build` makes the
whole screen (and every row) rebuild on every "+" even on another screen —
subscribe where the value is shown, not where it is convenient. (Reverted.)

In the final app each row uses
`context.select<Cart, bool>((c) => c.qtyOf(book) > 0)`, so one tap on Add
rebuilds **1 row** (and the badge), not 6.

## Level 5 — Where does it live?

| Value | Home | Why |
| ----- | ---- | --- |
| The cart | **provided** (`ChangeNotifierProvider` above `MaterialApp`) | Two routes and the badge need it; it must survive navigation and be reachable from anywhere without passing parameters. |
| Search text in the Books AppBar | **ephemeral** (`State` of `BooksScreen`) | Only that one screen uses it; it is fine to lose it when the screen is gone. |
| Cart total expanded / collapsed | **ephemeral** (`State` of the total widget) | One widget cares, nobody else needs to know; resets when the screen closes. |
| Theme mode (dark-mode switch) | **provided** (or lifted into `Shell`) | `MaterialApp` reads it and a switch somewhere deep must change it — it lives above everything that needs it. |