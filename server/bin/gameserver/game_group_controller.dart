import 'package:bloc/bloc.dart';
import 'package:common/common.dart';

import '../mediators/server_mediator.dart';
import '../services/service_locator.dart';

class GameGroupController extends Cubit<GameGroup> {
  GameGroupController(GameGroup initial) : super(initial);

  String get id => state.id;
  Map<String, dynamic> toMap() => state.toMap();
  List<String> get unreadyPlayers => state.players.where((e) => !state.words.containsKey(e)).toList();

  Result<bool> addPlayer(String id) {
    if (state.players.contains(id)) return Result.error('already_in_group');
    if (state.state > MatchState.lobby) return Result.error('group_started');
    emit(state.copyWith(
      players: List.from(state.players)..add(id),
    ));
    return Result.ok(true);
  }

  /// Removes a player with [id] from the group.
  /// Returns true if the group is to be deleted.
  Result<bool> removePlayer(String id) {
    if (state.state > MatchState.lobby) return Result.error('group_started');
    if (!state.players.contains(id)) return Result.error('not_in_group');
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
    if (state.state > MatchState.lobby) return Result.error('group_started');
    if (state.players.length < 2) return Result.error('not_enough_players');
    if (unreadyPlayers.isNotEmpty) {
      return Result.error('players_not_ready', unreadyPlayers);
    }
    return Result.ok(true);
  }

  void start(Map<String, List<String>> games) {
    emit(state.copyWith(
      state: MatchState.playing,
      games: games,
    ));
  }

  Result<bool> setWord(String player, String word) {
    if (state.state > MatchState.lobby) return Result.error('group_started');
    if (!state.players.contains(player)) return Result.error('not_in_group');
    if (word.length != state.config.wordLength) return Result.error('invalid_word');
    if (!dictionary().isValidWord(word)) return Result.error('invalid_word');
    emit(state.copyWith(words: Map.from(state.words)..[player] = word));
    return Result.ok(true);
  }
}
