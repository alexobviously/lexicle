import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:word_game/services/api_client.dart';
import '../services/service_locator.dart';

class GameGroupController extends Cubit<GameGroup> {
  GameGroupController(GameGroup initial) : super(initial) {
    timer = Timer.periodic(Duration(milliseconds: 5000), _onTimerEvent);
  }

  late Timer timer;

  String get id => state.id;
  String get player => auth().state.name;
  Map<String, dynamic> toMap({bool hideAnswers = true}) => state.toMap(hideAnswers: hideAnswers);
  List<String> get unreadyPlayers => state.players.where((e) => !state.words.containsKey(e)).toList();

  void _onTimerEvent(Timer t) {
    print('on timer event');
    refresh();
  }

  @override
  Future<void> close() {
    timer.cancel();
    return super.close();
  }

  Result<bool> get canStart {
    if (player != state.creator) return Result.error('unauthorised');
    if (state.state > MatchState.lobby) return Result.error('group_started');
    if (state.players.length < 2) return Result.error('not_enough_players');
    if (unreadyPlayers.isNotEmpty) {
      return Result.error('players_not_ready', unreadyPlayers);
    }
    return Result.ok(true);
  }

  void refresh() async {
    final _result = await ApiClient.getGroup(id);
    if (_result.ok && !isClosed) {
      emit(_result.object!);
    }
  }

  void start() async {
    final _result = await ApiClient.startGroup(id);
    if (_result.ok) {
      emit(_result.object!);
    }
  }

  Future<Result<GameGroup>> setWord(String word) async {
    if (state.state > MatchState.lobby) return Result.error('group_started');
    if (!state.players.contains(player)) return Result.error('not_in_group');
    if (word.length != state.config.wordLength) return Result.error('invalid_word');
    if (!dictionary().isValidWord(word)) return Result.error('invalid_word');
    final _result = await ApiClient.setWord(id, player, word);
    if (_result.ok) {
      emit(_result.object!);
    }
    return _result;
  }

  void setState(int _state) => emit(state.copyWith(state: _state));
}

class GameGroupState {
  final bool loading;
  final GameGroup? group;

  GameGroupState({this.loading = false, this.group});
}
