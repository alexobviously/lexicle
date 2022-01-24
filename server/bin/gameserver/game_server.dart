import 'package:common/common.dart';
import '../mediators/server_mediator.dart';
import '../utils/string_utils.dart';
import 'game_group_controller.dart';

class GameServer with ReadyManager {
  Map<String, GameGroupController> gameGroups = {};
  Map<String, String> privateGroups = {};
  Map<String, GameController> games = {}; // gamecontroller when it's made

  @override
  void initialise() {
    setReady();
  }

  String createGame({required String creator, required GameConfig config, bool private = false}) {
    String id = newId();
    GameGroup gg = GameGroup(id: id, title: '$creator\'s game', config: config, creator: creator);
    GameGroupController ggc = GameGroupController(gg);
    gameGroups[id] = ggc;
    return id;
  }

  void deleteGroup(String id) {
    if (!gameGroups.containsKey(id)) return;
    // todo: dispose?
    GameGroupController ggc = gameGroups[id]!;
    if (ggc.state.state > MatchState.lobby) return;
    if (ggc.state.code != null) {
      privateGroups.remove(ggc.state.code);
    }
    gameGroups.remove(id);
  }

  void leaveGroup(String id, String player) {
    if (!gameGroups.containsKey(id)) return;
    GameGroupController ggc = gameGroups[id]!;
    bool shouldDelete = ggc.removePlayer(player);
    if (shouldDelete) deleteGroup(id);
  }

  String getRandomCode([int maxAttempts = 300]) {
    int attempts = 0;
    while (attempts < maxAttempts) {
      String code = randomCode();
      if (!privateGroups.containsKey(code)) return code;
      attempts++;
    }
    throw ("Couldn't generate a code in $maxAttempts attempts");
  }

  Result<Map<String, List<String>>> createGamesForGroup(String id) {
    if (!gameGroups.containsKey(id)) return Result.error('not_found');
    GameGroup _group = gameGroups[id]!.state;
    Map<String, List<String>> _games = {};
    for (String p in _group.players) {
      List<String> playerGames = [];
      for (String c in _group.players) {
        if (c == p) continue;
        String gid = newId();
        Game g = Game(
          id: gid,
          answer: _group.words[c]!,
          player: p,
          creator: c,
          guesses: [],
          current: WordData.blank(),
        );
        games[gid] = GameController(g, ServerMediator(answer: _group.words[c]!));
        playerGames.add(gid);
      }
      _games[p] = playerGames;
    }
    return Result.ok(_games);
  }

  Future<Result<Game>> submitWord(String gameId, String word) async {
    if (!games.containsKey(gameId)) return Result.error('not_found');
    GameController gc = games[gameId]!;
    final _result = await gc.submitWord(word);
    return _result;
  }
}
