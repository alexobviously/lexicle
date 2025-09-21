import 'package:common/common.dart';
import 'package:word_game/services/api_client.dart';

class AppUserStore extends UserStore {
  AppUserStore(DatabaseService db) : super(db);

  Future<Result<User>> getMe() async {
    final result = await ApiClient.getMe();
    if (result.ok) onGet(result.object!);
    return result;
  }
}
