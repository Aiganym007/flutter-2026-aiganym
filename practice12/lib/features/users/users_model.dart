import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';

sealed class UsersState {
  const UsersState();
}

final class UsersLoading extends UsersState {
  const UsersLoading();
}

final class UsersLoaded extends UsersState {
  const UsersLoaded(this.users);
  final List<User> users;
}

final class UsersFailed extends UsersState {
  const UsersFailed(this.error);
  final ApiException error;
}

class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);
  final UserRepository _repo;
  UsersState _state = const UsersLoading();
  bool _fromCache = false;
  UsersState get state => _state;
  bool get fromCache => _fromCache;

  List<String> get cities {
    final s = _state;
    if (s is! UsersLoaded) return const [];
    return ({for (final u in s.users) u.address.city}.toList()..sort());
  }

  Future<void> load() async {
    if (_state is! UsersLoaded) {
      _state = const UsersLoading();
      notifyListeners();
    }
    try {
      final r = await _repo.getAll();
      _state = UsersLoaded(r.items);
      _fromCache = r.fromCache;
    } on ApiException catch (e) {
      if (_state is! UsersLoaded) _state = UsersFailed(e);
    }
    notifyListeners();
  }
}
