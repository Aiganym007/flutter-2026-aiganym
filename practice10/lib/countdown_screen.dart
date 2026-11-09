import 'dart:async';
import 'package:flutter/material.dart';
import 'api/countdown.dart';
class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  bool _versionA = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('A: StreamBuilder')),
                ButtonSegment(value: false, label: Text('B: listen')),
              ],
              selected: {_versionA},
              onSelectionChanged: (s) => setState(() => _versionA = s.first),
            ),
          ),
          Expanded(
            child: _versionA ? const _CountdownA() : const _CountdownB(),
          ),
        ],
      ),
    );
  }
}

class _CountdownA extends StatefulWidget {
  const _CountdownA();

  @override
  State<_CountdownA> createState() => _CountdownAState();
}

class _CountdownAState extends State<_CountdownA> {
  late final Stream<int> _stream = countdown(10);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _stream,
      builder: (context, snapshot) {
        return Center(
          child: Text(
            '${snapshot.data ?? 10}',
            style: Theme.of(context).textTheme.displayLarge,
          ),
        );
      },
    );
  }
}

class _CountdownB extends StatefulWidget {
  const _CountdownB();

  @override
  State<_CountdownB> createState() => _CountdownBState();
}

class _CountdownBState extends State<_CountdownB> {
  int _left = 10;
  late StreamSubscription<int> _sub;

  @override
  void initState() {
    super.initState();
    _sub = countdown(10).listen((i) => setState(() => _left = i));
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('$_left', style: Theme.of(context).textTheme.displayLarge),
    );
  }
}