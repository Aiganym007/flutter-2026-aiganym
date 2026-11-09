import 'package:flutter/material.dart';
import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';
class StudentsFutureScreen extends StatefulWidget {
  const StudentsFutureScreen({super.key});

  @override
  State<StudentsFutureScreen> createState() => _StudentsFutureScreenState();
}

class _StudentsFutureScreenState extends State<StudentsFutureScreen> {
  final _api = FakeApi();
  late Future<List<Student>> _future;
  bool _compact = false;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchStudents();
  }

  void _retry() {
    setState(() {
      _future = _api.fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FutureBuilder'),
        actions: [
          const Text('Compact'),
          Switch(
            value: _compact,
            onChanged: (value) => setState(() => _compact = value),
          ),
        ],
      ),
      body: FutureBuilder<List<Student>>(
        key: ObjectKey(_future),
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) return ErrorView(onRetry: _retry);
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView();
          }
          final list = snapshot.data ?? const <Student>[];
          if (list.isEmpty) return const EmptyView();
          return StudentList(list, compact: _compact);
        },
      ),
    );
  }
}