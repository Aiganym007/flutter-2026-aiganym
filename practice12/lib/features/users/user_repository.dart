import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_cache.dart';

typedef UsersResult = ({List<User> items, bool fromCache});

class UserRepository {
  UserRepository(this._api, this._cache);
  final ApiClient _api;
  final UsersCache _cache;

  Future<UsersResult> getAll() async {
    try {
      final fresh = await _fetch();
      try {
        await _cache.save(fresh);
      } catch (_) {
      }
      return (items: fresh, fromCache: false);
    } on NoConnectionException {
      final saved = await _cache.load();
      if (saved == null) rethrow;
      return (items: saved, fromCache: true);
    }
  }

  Future<List<User>> _fetch() async {
    final json = await _api.getJson('/users');
    if (json is! List) throw const BadResponseException();
    try {
      return [for (final e in json) User.fromJson(e as Map<String, dynamic>)];
    } on TypeError {
      throw const BadResponseException();
    }
  }
}
