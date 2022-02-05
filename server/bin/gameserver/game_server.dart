import 'dart:async';

import 'package:common/common.dart';
import '../mediators/server_mediator.dart';
import '../services/service_locator.dart';
import '../utils/string_utils.dart';
import 'game_group_controller.dart';

class GameServer with ReadyManager {
  Map<String, GameGroupController> gameGroups = {};
  Map<String, String> privateGroups = {};
  Map<String, GameController> games = {};
  Map<String, StreamSubscription<Game>> gameSubs = {};
  Map<String, StreamSubscription<GameGroup>> groupSubs = {};

  @override
  void initialise() {
    setReady();
  }

  void _handleGameUpdate(Game g) {
    gameStore().set(g, g.gameFinished);
    if (g.gameFinished) {
      final sub = gameSubs[g.id];
      sub?.cancel();
      gameSubs.remove(g.id);
    }
  }

  void _handleGroupUpdate(GameGroup g) {
    groupStore().set(g, g.finished);
    if (g.finished) {
      final sub = groupSubs[g.id];
      sub?.cancel();
      groupSubs.remove(g.id);
    }
  }

  Result<GameGroupController> createGameGroup({
    required String creator,
    required String title,
    required GameConfig config,
    bool private = false,
  }) {
    String id = newId();
    GameGroup gg = GameGroup(id: id, title: title, config: config, creator: creator, players: [creator]);
    GameGroupController ggc = GameGroupController(gg);
    gameGroups[id] = ggc;
    final sub = ggc.stream.listen(_handleGroupUpdate);
    groupSubs[id] = sub;
    return Result.ok(ggc);
  }

  Result<GameGroupController> getGroupController(String id) {
    if (!gameGroups.containsKey(id)) return Result.error('not_found');
    return Result.ok(gameGroups[id]!);
  }

  Result<GameController> getGameController(String id) {
    if (!games.containsKey(id)) return Result.error('not_found');
    return Result.ok(games[id]!);
  }

  Result<GameGroupController> getGroupForGameId(String id) {
    final _result = getGameController(id);
    if (_result.ok) {
      return getGroupController(_result.object!.state.group ?? '');
    }
    return Result.error('not_found');
  }

  Result<GameGroupController> joinGroup(String id, String player) {
    if (!gameGroups.containsKey(id)) return Result.error('not_found');
    GameGroupController ggc = gameGroups[id]!;
    final _res = ggc.addPlayer(player);
    if (!_res.ok) {
      return Result.error(_res.error!);
    }
    return Result.ok(ggc);
  }

  Result<GameGroupController> leaveGroup(String id, String player) {
    if (!gameGroups.containsKey(id)) return Result.error('not_found');
    GameGroupController ggc = gameGroups[id]!;
    if (ggc.state.creator == player) return Result.error('own_group', ['must_delete']);
    Result _result = ggc.removePlayer(player);
    if (!_result.ok) {
      return Result.error(_result.error!);
    }
    return Result.ok(ggc);
  }

  Result<bool> deleteGroup(String id, String player) {
    if (!gameGroups.containsKey(id)) return Result.error('not_found');
    // todo: dispose?
    GameGroupController ggc = gameGroups[id]!;
    if (ggc.state.creator != player) return Result.error(('unauthorised'));
    if (ggc.state.state > MatchState.lobby) return Result.error('group_started');
    if (ggc.state.code != null) {
      privateGroups.remove(ggc.state.code);
    }
    gameGroups.remove(id);
    return Result.ok(true);
  }

  Result<GameGroupController> setWord(String id, String player, String word) {
    if (!gameGroups.containsKey(id)) return Result.error('not_found');
    GameGroupController ggc = gameGroups[id]!;
    final _result = ggc.setWord(player, word);
    if (!_result.ok) {
      return Result.error(_result.error!);
    }
    return Result.ok(ggc);
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

  Result<GameGroupController> startGroup(String id, String player) {
    if (!gameGroups.containsKey(id)) return Result.error('not_found');
    GameGroupController ggc = gameGroups[id]!;
    final _result = ggc.canStart;
    if (!_result.ok) {
      return Result.error(_result.error!, _result.warnings);
    }
    if (ggc.state.creator != player) return Result.error('unauthorised');
    ggc.start(createGamesForGroup(ggc));
    return Result.ok(ggc);
  }

  Map<String, List<GameStub>> createGamesForGroup(GameGroupController controller) {
    GameGroup _group = controller.state;
    Map<String, List<GameStub>> _games = {};
    for (String p in _group.players) {
      List<String> playerGames = [];
      _games[p] = [];
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
          group: controller.id,
        );
        games[gid] = GameController(g, ServerMediator(answer: _group.words[c]!));
        playerGames.add(gid);
        final sub = games[gid]!.stream.listen(_handleGameUpdate);
        gameSubs[gid] = sub;
        _games[p]!.add(g.stub);
      }
    }
    return _games;
  }

  List<String> getAllGroupIds() => gameGroups.entries.map((e) => e.value.id).toList();
  List<String> getAllGameIds() => games.entries.map((e) => e.value.state.id).toList();
  List<String> getAllActiveGameIds() =>
      games.entries.where((e) => !e.value.state.gameFinished).map((e) => e.value.state.id).toList();

  void updateGroupStatus(String id) {
    if (!gameGroups.containsKey(id)) return;
    GameGroupController ggc = gameGroups[id]!;
    if (ggc.state.state == MatchState.playing) {
      bool finished = true;
      for (final playerGames in ggc.state.gameIds.entries) {
        if (!finished) break;
        for (String g in playerGames.value) {
          final _result = getGameController(g);
          if (_result.ok) {
            if (!_result.object!.state.gameFinished) {
              finished = false;
              break;
            }
          }
        }
      }
      if (finished) {
        ggc.setState(MatchState.finished);
      }
    }
  }

  void updateStub(String player, GameStub stub) {
    String id = stub.id;
    final _result = getGroupForGameId(id);
    if (_result.ok) {
      _result.object!.updateStub(player, stub);
    }
  }

  Future<Result<WordValidationResult>> makeGuess(String gameId, String player, String word) async {
    if (!games.containsKey(gameId)) return Result.error('not_found');
    GameController gc = games[gameId]!;
    if (gc.state.player != player) return Result.error('unauthorised');
    final _result = await gc.submitWord(word);
    // note: invalid words count as ok
    if (!_result.ok) {
      return Result.error(_result.error!);
    }
    Game g = gc.state;
    updateStub(g.player, g.stub);
    if (g.group != null && g.gameFinished) updateGroupStatus(gc.state.group!);
    return Result.ok(_result.object!);
  }
}
