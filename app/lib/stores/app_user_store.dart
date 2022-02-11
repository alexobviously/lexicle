import 'package:common/common.dart';
import 'package:word_game/services/api_client.dart';

class AppUserStore extends UserStore {
  AppUserStore(DatabaseService db) : super(db);

  Future<Result<User>> getMe() async {
    final _result = await ApiClient.getMe();
    if (_result.ok) onGet(_result.object!);
    return _result;
  }
}
