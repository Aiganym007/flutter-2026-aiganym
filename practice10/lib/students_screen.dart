import 'package:flutter/material.dart';
import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';
class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student>? _students;
  Object? _error;
  final _api = FakeApi();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _students = null;
      _error = null;
    });
    try {
      final list = await _api.fetchStudents();
      if (!mounted) return;
      setState(() => _students = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<void> _save() async {
    final n = _students!.length;
    setState(() => _saving = true);
    var saved = false;
    try {
      await _api.save(n);
      if (!mounted) return;
      saved = true;
      Navigator.pop(context);
    } on StateError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (!saved && mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (_error != null) {
      body = ErrorView(onRetry: _load);
    } else if (_students == null) {
      body = const LoadingView();
    } else if (_students!.isEmpty) {
      body = const EmptyView();
    } else {
      body = StudentList(_students!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('By hand'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: _load,
          ),
        ],
      ),
      body: body,
      floatingActionButton: (_students == null || _error != null)
          ? null
          : FloatingActionButton(
        onPressed: _saving ? null : _save,
        child: _saving
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : const Icon(Icons.save),
      ),
    );
  }
}