import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:word_game/cubits/observer_game_controller.dart';
import 'package:word_game/mediator/online_mediator.dart';
import 'package:word_game/services/api_client.dart';
import '../services/service_locator.dart';

class GameGroupController extends Cubit<GameGroupState> {
  bool observing;
  GameGroupController(GameGroupState initial, {this.observing = false}) : super(initial) {
    init();
    startTimer(); // hmm
  }
  factory GameGroupController.observer(GameGroup group) =>
      GameGroupController(GameGroupState(group: group), observing: true);

  Timer? timer;
  StreamSubscription<bool>? finishedSub;

  String get id => state.group.id;
  String? get player => auth().userId;
  Map<String, dynamic> toMap({bool hideAnswers = true}) => state.group.toMap(hideAnswers: hideAnswers);
  List<String> get unreadyPlayers => state.group.players.where((e) => !state.group.words.containsKey(e)).toList();

  void init() {
    finishedSub = stream.map((e) => e.group.finished).distinct().listen((fin) {
      if (fin) {
        _onFinished();
      }
    });
  }

  void startTimer() => timer = Timer.periodic(Duration(milliseconds: 5000), _onTimerEvent);

  void _onTimerEvent(Timer t) {
    refresh();
  }

  void _onFinished() {
    auth().refresh();
    List<String> others = List.from(state.group.players)..remove(player);
    userStore().getMultiple(others, true);
    ustatsStore().getMultiple(others, true);
  }

  @override
  Future<void> close() {
    timer?.cancel();
    return super.close();
  }

  bool hasGameController(String gid) => state.games.containsKey(gid);

  void _createGameController(String gid) async {
    final _result = await ApiClient.getEntity<Game>(gid);
    if (!_result.ok) return; // should we do something here maybe?
    final gc = observing
        ? ObserverGameController(_result.object!)
        : GameController(_result.object!, OnlineMediator(gameId: gid, wordLength: _result.object!.length));
    emit(state.copyWith(games: Map.from(state.games)..[gid] = gc));
  }

  void _checkGames() {
    if (state.group.games.containsKey(player)) {
      for (String gid in state.group.gameIds[player]!) {
        if (!hasGameController(gid)) {
          _createGameController(gid);
        }
      }
    }
  }

  Result<bool> get canStart {
    if (player != state.group.creator) return Result.error(Errors.unauthorised);
    if (state.group.state > GroupState.lobby) return Result.error(Errors.groupStarted);
    if (state.group.players.length < 2) return Result.error(Errors.notEnoughPlayers);
    if (unreadyPlayers.isNotEmpty) {
      return Result.error(Errors.playersNotReady, unreadyPlayers);
    }
    return Result.ok(true);
  }

  void refresh() async {
    final _result = await ApiClient.getGroup(id);
    if (_result.ok && !isClosed) {
      emit(state.copyWith(group: _result.object!));
      _checkGames();
    }
  }

  void update(GameGroup g) {
    emit(state.copyWith(loading: false, group: g));
    _checkGames();
  }

  Future<bool> start() async {
    final _result = await ApiClient.startGroup(id);
    if (_result.ok) {
      emit(state.copyWith(group: _result.object!));
      _checkGames();
      return true;
    }
    return false;
  }

  Future<Result<GameGroup>> setWord(String word) async {
    if (player == null) return Result.error(Errors.unauthorised);
    if (state.group.state > GroupState.lobby) return Result.error(Errors.groupStarted);
    if (!state.group.players.contains(player)) return Result.error(Errors.notInGroup);
    if (word.length != state.group.config.wordLength) return Result.error(Errors.invalidWord);
    if (!dictionary().isValidWord(word)) return Result.error(Errors.invalidWord);
    final _result = await ApiClient.setWord(id, player!, word);
    if (_result.ok) {
      emit(state.copyWith(group: _result.object!));
    }
    return _result;
  }

  Future<Result<GameGroup>> kickPlayer(String player) async {
    if (state.group.state > GroupState.lobby) return Result.error(Errors.groupStarted);
    if (state.group.creator != auth().userId) return Result.error(Errors.unauthorised);
    if (!state.group.players.contains(player)) return Result.error(Errors.notInGroup);
    final result = await ApiClient.kickPlayer(state.group.id, player);
    if (result.ok) {
      emit(state.copyWith(group: result.object!));
    }
    return result;
  }
}

class GameGroupState {
  final bool loading;
  final GameGroup group;
  final Map<String, BaseGameController> games;

  GameGroupState({
    this.loading = false,
    required this.group,
    this.games = const {},
  });

  GameGroupState copyWith({
    bool? loading,
    GameGroup? group,
    Map<String, BaseGameController>? games,
  }) =>
      GameGroupState(
        loading: loading ?? this.loading,
        group: group ?? this.group,
        games: games ?? this.games,
      );
}
