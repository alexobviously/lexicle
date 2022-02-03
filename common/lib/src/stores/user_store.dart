import 'package:common/common.dart';

class UserStore extends EntityStore<User> {
  UserStore(DatabaseService db) : super(db);

  Future<Result<User>> getByUsername(String username) async {
    final found = items.values.firstWhereOrNull((e) => e.username == username);
    if (found != null) return Result.ok(found);
    return getByField(UserFields.username, username);
  }
}
