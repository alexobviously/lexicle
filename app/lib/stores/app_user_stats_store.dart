import 'package:common/common.dart';
import 'package:word_game/services/api_client.dart';

class AppUserStatsStore extends UserStatsStore {
  AppUserStatsStore(DatabaseService db) : super(db);

  Future<Result<UserStats>> getMe() async {
    final _result = await ApiClient.getMyStats();
    if (_result.ok) onGet(_result.object!);
    return _result;
  }
}
