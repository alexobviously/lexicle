import 'dart:async';
import 'dart:math';

import 'package:common/common.dart';
import 'package:rxdart/subjects.dart';
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
    updateStub(g.player, g.stub);
    GameController gc = games[g.id]!;
    if (g.group != null) {
      if (gameGroups.containsKey(g.group)) {
        gameGroups[g.group]!.onGameUpdate(g);
      }
      if (g.gameFinished) updateGroupStatus(gc.state.group!);
    }

    if (g.gameFinished) {
      final sub = gameSubs[g.id];
      sub?.cancel();
      gameSubs.remove(g.id);
      if (g.challenge != null) updateChallengeStats(g);
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

  GameController _registerGame(Game game, {Mediator? mediator, BehaviorSubject<int>? highestGuessStream}) {
    GameController gc = GameController(game, mediator ?? ServerMediator(answer: game.answer));
    String id = gc.id;
    games[id] = gc;
    if (highestGuessStream != null) gc.registerHighestGuessStream(highestGuessStream);
    if (!game.gameFinished) {
      final sub = gc.stream.listen(_handleGameUpdate);
      gameSubs[id] = sub;
    }
    return gc;
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
    if (!gameGroups.containsKey(id)) return Result.error(Errors.notFound);
    return Result.ok(gameGroups[id]!);
  }

  Future<Result<GameController>> getGameController(String id, {bool checkStore = true}) async {
    if (!games.containsKey(id)) {
      if (checkStore) {
        final result = await gameStore().get(id);
        if (result.ok) {
          return Result.ok(_registerGame(result.object!));
        }
      }
      return Result.error(Errors.notFound);
    }
    return Result.ok(games[id]!);
  }

  Future<Result<GameGroupController>> getGroupForGameId(String id) async {
    final result = await getGameController(id);
    if (result.ok) {
      return getGroupController(result.object!.state.group ?? '');
    }
    return Result.error(Errors.notFound);
  }

  Result<GameGroupController> joinGroup(String id, String player) {
    if (!gameGroups.containsKey(id)) return Result.error(Errors.notFound);
    GameGroupController ggc = gameGroups[id]!;
    final _res = ggc.addPlayer(player);
    if (!_res.ok) {
      return Result.error(_res.error!);
    }
    return Result.ok(ggc);
  }

  Result<GameGroupController> leaveGroup(String id, String player) {
    if (!gameGroups.containsKey(id)) return Result.error(Errors.notFound);
    GameGroupController ggc = gameGroups[id]!;
    if (ggc.state.creator == player) return Result.error('own_group', ['must_delete']);
    Result _result = ggc.removePlayer(player);
    if (!_result.ok) {
      return Result.error(_result.error!);
    }
    return Result.ok(ggc);
  }

  Result<bool> deleteGroup(String id, String player) {
    if (!gameGroups.containsKey(id)) return Result.error(Errors.notFound);
    // todo: dispose?
    GameGroupController ggc = gameGroups[id]!;
    if (ggc.state.creator != player) return Result.error(Errors.unauthorised);
    if (ggc.state.state > GroupState.lobby) return Result.error(Errors.groupStarted);
    if (ggc.state.code != null) {
      privateGroups.remove(ggc.state.code);
    }
    gameGroups.remove(id);
    return Result.ok(true);
  }

  Result<GameGroupController> setWord(String id, String player, String word) {
    if (!gameGroups.containsKey(id)) return Result.error(Errors.notFound);
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
    // TODO: deprecate using player here and just authenticate in handler
    if (!gameGroups.containsKey(id)) return Result.error(Errors.notFound);
    GameGroupController ggc = gameGroups[id]!;
    final _result = ggc.canStart;
    if (!_result.ok) {
      return Result.error(_result.error!, _result.warnings);
    }
    if (ggc.state.creator != player) return Result.error(Errors.unauthorised);
    int? endTime = ggc.getEndTime();
    ggc.start(createGamesForGroup(ggc, endTime), endTime);
    return Result.ok(ggc);
  }

  Map<String, List<GameStub>> createGamesForGroup(GameGroupController controller, [int? endTime]) {
    GameGroup _group = controller.state;
    Map<String, List<GameStub>> _games = {};
    for (String p in _group.players) {
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
          endTime: endTime,
        );
        gameStore().set(g);
        _registerGame(g, highestGuessStream: controller.highestGuessStream);
        _games[p]!.add(g.stub);
      }
    }
    return _games;
  }

  List<String> getAllGroupIds() => gameGroups.entries.map((e) => e.value.id).toList();
  List<String> getAllGameIds() => games.entries.map((e) => e.value.state.id).toList();
  List<String> getAllActiveGameIds() =>
      games.entries.where((e) => !e.value.state.gameFinished).map((e) => e.value.state.id).toList();

  void updateGroupStatus(String id) async {
    if (!gameGroups.containsKey(id)) return;
    GameGroupController ggc = gameGroups[id]!;
    if (ggc.state.state == GroupState.playing) {
      bool finished = true;
      for (final playerGames in ggc.state.gameIds.entries) {
        if (!finished) break;
        for (String g in playerGames.value) {
          final _result = await getGameController(g);
          if (_result.ok) {
            if (!_result.object!.state.gameFinished) {
              finished = false;
              break;
            }
          }
        }
      }
      if (finished) {
        onGroupFinished(ggc);
      }
    }
  }

  void onGroupFinished(GameGroupController ggc) async {
    // update user ratings
    ggc.setState(GroupState.finished);
    List<PlayerResult> pr = await Future.wait(
      ggc.state.standings
          .map((e) async => PlayerResult(
                id: e.player,
                rating: (await userStore().get(e.player)).object!.rating,
                score: e.guesses,
              ))
          .toList(),
    );
    final ratings = adjustRatings(pr);
    ratings.forEach((u, r) => userStore().updateRating(u, r));

    // update user stats
    final group = ggc.state;
    final wordLength = group.config.wordLength;
    for (String player in group.players) {
      final sResult = await ustatsStore().get(player);
      UserStats stats = sResult.ok ? sResult.object! : UserStats(id: player);
      List<WordDifficulty> _words = List.from(stats.words);
      _words.add(WordDifficulty(group.words[player]!, group.wordDifficulty(player)));
      Map<int, int> _numGroups = Map.from(stats.numGroups);
      _numGroups[wordLength] = (_numGroups[wordLength] ?? 0) + 1;
      Map<int, int> _numGames = Map.from(stats.numGames);
      _numGames[wordLength] = (_numGames[wordLength] ?? 0) + group.players.length - 1;
      Map<int, int> _guessCounts = Map.from(stats.guessCounts[wordLength] ?? {});
      Map<int, int> _timeouts = Map.from(stats.timeouts);
      for (GameStub g in group.games[player]!) {
        if (g.endReason == EndReasons.solved) {
          _guessCounts[g.guesses] = (_guessCounts[g.guesses] ?? 0) + 1;
        } else if (g.endReason == EndReasons.timeout) {
          _timeouts[wordLength] = (_timeouts[wordLength] ?? 0) + 1;
        }
      }
      Map<int, Map<int, int>> _gcAll = Map.from(stats.guessCounts);
      _gcAll[group.config.wordLength] = _guessCounts;
      Map<int, int>? _wins;
      // it counts as a win for all players tied for first
      if (group.standings.first.player == player || group.standings.first.guesses == group.playerGuesses(player)) {
        _wins = Map.from(stats.wins);
        _wins[wordLength] = (_wins[wordLength] ?? 0) + 1;
      }
      stats = stats.copyWith(
        words: _words,
        numGroups: _numGroups,
        numGames: _numGames,
        guessCounts: _gcAll,
        wins: _wins,
        timeouts: _timeouts,
      );
      ustatsStore().write(stats);
    }
  }

  void updateChallengeStats(Game g) async {
    if (g.challenge == null) return;

    final cResult = await challengeStore().get(g.challenge!);
    if (!cResult.ok) return;
    Challenge challenge = cResult.object!;
    if (challenge.level == null || challenge.sequence == null) return; // maybe we want to handle this in future?

    final uResult = await ustatsStore().get(g.player);
    if (!uResult.ok) return;
    UserStats stats = uResult.object!;

    // don't need to update if the last completed was this one
    if ((stats.challengeStats[challenge.level!]?.lastCompleted ?? -1) <= (challenge.sequence ?? 0)) return;

    Map<int, ChallengeStats> cStatsMap = Map.from(stats.challengeStats);
    ChallengeStats cStats = stats.challengeStats[challenge.level] ?? ChallengeStats(level: challenge.level!);
    int streak = cStats.currentStreak + 1;
    int bestStreak = max(cStats.bestStreak, streak);
    int lastCompleted = challenge.sequence!;
    Map<int, int> guessCounts = Map.from(cStats.guessCounts);
    guessCounts[g.score] = (guessCounts[g.score] ?? 0) + 1;
    cStats = cStats.copyWith(
      streak: streak,
      bestStreak: bestStreak,
      lastCompleted: lastCompleted,
      guessCounts: guessCounts,
      streakExpiry: challenge.endTime + Challenges.duration(challenge.level!),
    );
    cStatsMap[challenge.level!] = cStats;

    stats = stats.copyWith(challengeStats: cStatsMap);
    ustatsStore().set(stats, true);
  }

  void updateStub(String player, GameStub stub) async {
    String id = stub.id;
    final _result = await getGroupForGameId(id);
    if (_result.ok) {
      _result.object!.updateStub(player, stub);
    }
  }

  Future<Result<WordValidationResult>> makeGuess(String gameId, String player, String word) async {
    final result = await getGameController(gameId);
    if (!result.ok) return Result.error(result.error!);
    GameController gc = games[gameId]!;
    if (gc.state.player != player) return Result.error(Errors.unauthorised);
    final _result = await gc.makeGuess(word);
    // note: invalid words count as ok
    if (!_result.ok) {
      return Result.error(_result.error!);
    }
    return Result.ok(_result.object!);
  }

  Future<Result<GameGroupController>> restoreGroup(String id) async {
    final result = await groupStore().get(id);
    if (!result.ok) return Result.error(result.error!);
    final group = result.object!;
    int numGames = group.games.entries.fold(0, (p, e) => p + e.value.length);
    final _games = await gameStore().getGamesForGroup(id);
    if (_games.length != numGames) return Result.error('games_missing');

    GameGroupController ggc = GameGroupController(group);
    gameGroups[id] = ggc;
    final sub = ggc.stream.listen(_handleGroupUpdate);
    groupSubs[id] = sub;

    // get highest guess
    int highestGuess = _games.fold(0, (p, g) => max(p, g.guesses.length));

    for (Game g in _games) {
      games[g.id] = GameController(g, ServerMediator(answer: g.answer));
      games[g.id]!.registerHighestGuessStream(ggc.highestGuessStream, initial: highestGuess);
      final sub = games[g.id]!.stream.listen(_handleGameUpdate);
      gameSubs[g.id] = sub;
    }
    ggc.start(group.games, ggc.getEndTime());
    return Result.ok(ggc);
  }
}
