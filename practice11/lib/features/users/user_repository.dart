import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  UserRepository(this._api);
  final ApiClient _api;

  Future<List<User>> getAll() async {
    final response = await _api.get('/users');
    return _readList(response, 'users');
  }

  Future<User> getById(int id) async {
    final response = await _api.get('/users/$id');
    return _readUser(response, 'users/$id');
  }

  Future<User> create(User draft) async {
    final response = await _api.post('/users', draft.toJson());
    if (response.statusCode != 201) {
      throw BadResponseException(
        'POST users: expected 201, got ${response.statusCode}',
      );
    }
    return _readUser(response, 'POST users');
  }

  List<User> _readList(http.Response response, String what) {
    final body = _api.decode(response);
    return _guard(what, () {
      return (body as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  User _readUser(http.Response response, String what) {
    final body = _api.decode(response);
    return _guard(what, () => User.fromJson(body as Map<String, dynamic>));
  }

  T _guard<T>(String what, T Function() parse) {
    try {
      return parse();
    } on TypeError catch (e) {
      throw BadResponseException('$what: $e');
    } on FormatException catch (e) {
      throw BadResponseException('$what: $e');
    }
  }
}
