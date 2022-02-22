import 'package:common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';

class GameGroupStore extends EntityStore<GameGroup> {
  GameGroupStore(DatabaseService db) : super(db);

  Future<List<GameGroup>> getForPlayer(String player) async {
    final groups = await db.getAll<GameGroup>(
        selector: where.eq(GroupFields.players, player).sortBy(Fields.timestamp, descending: true));
    for (GameGroup g in groups) {
      onGet(g);
    }
    return groups;
  }
}
