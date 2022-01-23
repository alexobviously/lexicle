import 'package:bloc/bloc.dart';
import 'package:common/common.dart';

import '../utils/string_utils.dart';

class GameGroupController extends Cubit<GameGroup> {
  GameGroupController(GameGroup initial) : super(initial);

  bool addPlayer(String id) {
    if (state.players.contains(id)) return false;
    if (state.state > MatchState.lobby) return false;
    emit(state.copyWith(
      players: List.from(state.players)..add(id),
    ));
    return true;
  }

  /// Removes a player with [id] from the group.
  /// Returns true if the group is to be deleted.
  bool removePlayer(String id) {
    if (state.state > MatchState.lobby) return false;
    if (!state.players.contains(id)) return false;
    if (id == state.creator) {
      if (state.players.length > 1) {
        return false;
      } else {
        emit(state.copyWith(players: [], words: {}));
        return true;
      }
    }
    emit(state.copyWith(
      players: List.from(state.players)..remove(id),
      words: Map.from(state.words)..remove(id),
    ));
    return false;
  }

  bool start(Map<String, List<String>> games) {
    if (state.state > MatchState.lobby) return false;
    emit(state.copyWith(
      state: MatchState.playing,
      games: games,
    ));
    return true;
  }
}
