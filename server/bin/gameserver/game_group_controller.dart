import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:rxdart/rxdart.dart';

import '../services/service_locator.dart';

class GameGroupController extends Cubit<GameGroup> {
  GameGroupController(GameGroup initial) : super(initial);

  String get id => state.id;
  Map<String, dynamic> toMap({bool hideAnswers = true}) => state.toMap(hideAnswers: hideAnswers);
  List<String> get unreadyPlayers => state.players.where((e) => !state.words.containsKey(e)).toList();
  GameConfig get config => state.config;

  BehaviorSubject<int> highestGuessStream = BehaviorSubject()..add(0);

  void onGameUpdate(Game g) {
    // we keep track of the highest guess count in every game to
    // calculate the penalty for timed-out games
    if (g.guesses.length > highestGuessStream.value) {
      print('set highest guess to ${g.guesses.length}');
      highestGuessStream.add(g.guesses.length);
    }
  }

  Result<bool> addPlayer(String id) {
    if (state.players.contains(id)) return Result.error('already_in_group');
    if (state.state > MatchState.lobby) return Result.error(Errors.groupStarted);
    emit(state.copyWith(
      players: List.from(state.players)..add(id),
    ));
    return Result.ok(true);
  }

  /// Removes a player with [id] from the group.
  /// Returns true if the group is to be deleted.
  Result<bool> removePlayer(String id) {
    if (state.state > MatchState.lobby) return Result.error(Errors.groupStarted);
    if (!state.players.contains(id)) return Result.error(Errors.notInGroup);
    if (id == state.creator) {
      if (state.players.length > 1) {
        return Result.error('cant_leave');
      } else {
        emit(state.copyWith(players: [], words: {}));
        return Result.ok(true);
      }
    }
    emit(state.copyWith(
      players: List.from(state.players)..remove(id),
      words: Map.from(state.words)..remove(id),
    ));
    return Result.ok(false);
  }

  Result<bool> get canStart {
    if (state.state > MatchState.lobby) return Result.error(Errors.groupStarted);
    if (state.players.length < 2) return Result.error(Errors.notEnoughPlayers);
    if (unreadyPlayers.isNotEmpty) {
      return Result.error(Errors.playersNotReady, unreadyPlayers);
    }
    return Result.ok(true);
  }

  int? getEndTime() => config.timeLimit != null
      ? DateTime.now().add(Duration(milliseconds: config.timeLimit!)).millisecondsSinceEpoch
      : null;

  void start(Map<String, List<GameStub>> games, int? endTime) {
    endTime ??= getEndTime();
    emit(state.copyWith(
      state: MatchState.playing,
      games: games,
      endTime: endTime,
    ));
  }

  Result<bool> setWord(String player, String word) {
    if (state.state > MatchState.lobby) return Result.error(Errors.groupStarted);
    if (!state.players.contains(player)) return Result.error(Errors.notInGroup);
    if (word.length != state.config.wordLength) return Result.error(Errors.invalidWord);
    if (!dictionary().isValidWord(word)) return Result.error(Errors.invalidWord);
    emit(state.copyWith(words: Map.from(state.words)..[player] = word));
    return Result.ok(true);
  }

  void updateStub(String player, GameStub stub) {
    emit(state.updateGameStub(player, stub));
  }

  void setState(int _state) => emit(state.copyWith(state: _state));
}
