# Practice 10 — The Data Arrives Later (NOTES)

## Level 1 — order of events

main() used for the experiment:

```dart
print('A');
Future.delayed(const Duration(seconds: 2), () => print('B'));
print('C');
final api = FakeApi();
api.fetchStudents().then((l) => print('${l.length} students'));
runApp(const StudentsApp());
```

**Predicted:** A, C, (first frame of the app), then 2 seconds later B and 6 students.

**Actual:** A, C, the first frame was drawn, and only about two seconds later B and
`6 students`. Nothing waited for the timer: main() ran to the end, the event loop
drew the screen, and the two callbacks arrived later as events.

Three `fetchStudents()` calls in a row: the third one prints
`Unhandled Exception: Instance of 'NoConnectionException'` and the app keeps running.

Breaking it with `sleep(const Duration(seconds: 2))` from `dart:io`: the first frame
was delayed by two seconds — the loop was blocked, not waiting. Put `await` back.

## Level 2 — guard against a dead State

Without both `if (!mounted) return;` lines, opening the screen and pressing Back
within two seconds gives:

```
setState() called after dispose(): _StudentsScreenState#xxxxx(lifecycle state: defunct, not mounted)
```

Guards put back: with them the console stays clean.

## Level 3 — FutureBuilder

- `_future` as a field: one `fetchStudents #1`, flipping the Switch ten times does not
  flicker and does not send a new request.
- `future: _api.fetchStudents()` inline in build: a spinner on every flip, the console
  counts `#2 #3 #4 …`, the third request fails. Field put back.
- Swapping the first two branches (hasData first) with a server that always throws:
  spinner forever. Order restored: error first.

## Level 4 — countdown

- Version B without `_sub.cancel()`: Back at 7, one second later
  `setState() called after dispose()` and the console keeps printing
  `tick 6, tick 5 … tick 0` with nobody on screen. That is the leak.
- Version A (StreamBuilder), no cancel in my code, Back at 7: the console stops.
  StreamBuilder cancelled the subscription for me.
- `_sub.cancel()` put back.

## Level 5 — errors that do not vanish

Bad version `onPressed: () { _api.save(n); Navigator.pop(context); }`:
`flutter analyze` flags it with `unawaited_futures`. The screen closed as if the save
worked, and the console said `Unhandled Exception: Bad state: server rejected 6`.

**The user saw a success, but the server said no — and the error was lost in the console.**

Honest version: awaited, `try / on StateError`, `context.mounted` after the await,
pop only on success, SnackBar only on failure, the button is disabled with a small
spinner while `_saving` is true.