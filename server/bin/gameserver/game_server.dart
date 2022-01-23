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
        games[gid] = GameController(
          player: p,
          length: _group.words[c]!.length,
          mediator: ServerMediator(answer: _group.words[c]!),
        );
        playerGames.add(gid);
      }
      _games[p] = playerGames;
    }
    return Result.ok(_games);
  }
}
