import 'package:common/common.dart';

class GameStore extends EntityStore<Game> {
  GameStore(DatabaseService db) : super(db);

  Future<List<Game>> getGamesForGroup(String groupId) async {
    final games = await db.getAllByField<Game>(GameFields.group, groupId);
    for (Game g in games) {
      onGet(g);
    }
    return games;
  }

  Future<Result<Game>> getChallengeAttempt(
    String player,
    String challenge,
  ) async {
    final game = items.values.firstWhereOrNull(
      (e) => e.player == player && e.challenge == challenge,
    );
    if (game != null) return Result.ok(game);

    final result = await db.getChallengeAttempt(player, challenge);
    if (result.ok) {
      onGet(result.object!);
      return Result.ok(result.object!);
    }

    return Result.error(result.error!);
  }
}
