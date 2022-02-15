import 'package:common/common.dart';

class GameStore extends EntityStore<Game> {
  GameStore(DatabaseService db) : super(db);

  Future<List<Game>> getGamesForGroup(String groupId) async {
    final _games = await db.getAllByField<Game>(GameFields.group, groupId);
    for (Game g in _games) {
      onGet(g);
    }
    return _games;
  }
}
