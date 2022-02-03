import 'package:common/common.dart';

class UserStore extends EntityStore<User> {
  UserStore(DatabaseService db) : super(db);
}
