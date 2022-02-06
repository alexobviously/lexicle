import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:word_game/mediator/offline_mediator.dart';
import 'package:word_game/services/service_locator.dart';

class LocalGameManager extends Cubit<LocalGameManagerState> {
  LocalGameManager() : super(LocalGameManagerState.initial());

  void createGame(GameConfig config) {
    String _answer = dictionary().randomWord(config.wordLength);
    Mediator _mediator = OfflineMediator(answer: _answer);
    int? endTime = config.timeLimit != null
        ? DateTime.now().add(Duration(milliseconds: config.timeLimit!)).millisecondsSinceEpoch
        : null;
    GameController _gc = GameController.initial(
      player: 'player',
      length: config.wordLength,
      mediator: _mediator,
      endTime: endTime,
    );
    List<GameController> _games = List.from(state.games);
    _games.add(_gc);
    emit(state.copyWith(games: _games));
  }

  void removeGame(String id) {
    int index = state.games.indexWhere((e) => e.state.id == id);
    if (index == -1) return;
    List<GameController> _games = List.from(state.games);
    _games.removeAt(index);
    emit(state.copyWith(games: _games));
  }

  Stream<int> get numGamesStream => stream.map((e) => e.games.length).distinct();
}

class LocalGameManagerState {
  final List<GameController> games;
  LocalGameManagerState({this.games = const []});
  factory LocalGameManagerState.initial() => LocalGameManagerState();

  LocalGameManagerState copyWith({List<GameController>? games}) => LocalGameManagerState(games: games ?? this.games);
}
