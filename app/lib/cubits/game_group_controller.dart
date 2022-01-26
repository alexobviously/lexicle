import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:word_game/services/api_client.dart';
import '../services/service_locator.dart';

class GameGroupController extends Cubit<GameGroupState> {
  GameGroupController(GameGroupState initial) : super(initial) {
    startTimer(); // hmm
  }

  Timer? timer;

  String get id => state.group.id;
  String get player => auth().state.name;
  Map<String, dynamic> toMap({bool hideAnswers = true}) => state.group.toMap(hideAnswers: hideAnswers);
  List<String> get unreadyPlayers => state.group.players.where((e) => !state.group.words.containsKey(e)).toList();

  void startTimer() => timer = Timer.periodic(Duration(milliseconds: 5000), _onTimerEvent);

  void _onTimerEvent(Timer t) {
    print('on timer event');
    refresh();
  }

  @override
  Future<void> close() {
    timer?.cancel();
    return super.close();
  }

  Result<bool> get canStart {
    if (player != state.group.creator) return Result.error('unauthorised');
    if (state.group.state > MatchState.lobby) return Result.error('group_started');
    if (state.group.players.length < 2) return Result.error('not_enough_players');
    if (unreadyPlayers.isNotEmpty) {
      return Result.error('players_not_ready', unreadyPlayers);
    }
    return Result.ok(true);
  }

  void refresh() async {
    final _result = await ApiClient.getGroup(id);
    if (_result.ok && !isClosed) {
      emit(state.copyWith(group: _result.object!));
    }
  }

  void start() async {
    final _result = await ApiClient.startGroup(id);
    if (_result.ok) {
      emit(state.copyWith(group: _result.object!));
    }
  }

  Future<Result<GameGroup>> setWord(String word) async {
    if (state.group.state > MatchState.lobby) return Result.error('group_started');
    if (!state.group.players.contains(player)) return Result.error('not_in_group');
    if (word.length != state.group.config.wordLength) return Result.error('invalid_word');
    if (!dictionary().isValidWord(word)) return Result.error('invalid_word');
    final _result = await ApiClient.setWord(id, player, word);
    if (_result.ok) {
      emit(state.copyWith(group: _result.object!));
    }
    return _result;
  }
}

class GameGroupState {
  final bool loading;
  final GameGroup group;
  final Map<String, GameController> games;

  GameGroupState({this.loading = false, required this.group, this.games = const {}});

  GameGroupState copyWith({
    bool? loading,
    GameGroup? group,
    Map<String, GameController>? games,
  }) =>
      GameGroupState(
        loading: loading ?? this.loading,
        group: group ?? this.group,
        games: games ?? this.games,
      );
}
