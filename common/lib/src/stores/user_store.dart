import 'package:common/common.dart';

class UserStore extends EntityStore<User> {
  UserStore(DatabaseService db) : super(db);

  Future<Result<User>> getByUsername(String username) async {
    final found = items.values.firstWhereOrNull((e) => e.username == username);
    if (found != null) return Result.ok(found);
    return getByField(UserFields.username, username);
  }

  Future<Result<User>> updateRating(String id, Rating rating, [bool forceWrite = true]) async {
    final _result = await get(id);
    if (!_result.ok) return _result;
    User u = _result.object!;
    u = u.copyWith(rating: rating);
    return set(u, forceWrite);
  }
}
