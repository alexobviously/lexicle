import 'package:bloc/bloc.dart';
import 'package:word_game/cubits/game_controller.dart';
import 'package:word_game/mediator/mediator.dart';
import 'package:word_game/mediator/offline_mediator.dart';
import 'package:word_game/model/game_config.dart';
import 'package:word_game/services/service_locator.dart';

class GameManager extends Cubit<GameManagerState> {
  GameManager() : super(GameManagerState.initial());

  void createLocalGame(GameConfig config) {
    String _answer = dictionary().randomWord(config.wordLength);
    Mediator _mediator = OfflineMediator(answer: _answer);
    GameController _gc = GameController(length: config.wordLength, mediator: _mediator);
    List<GameController> _games = List.from(state.games);
    _games.add(_gc);
    emit(state.copyWith(games: _games));
  }
}

class GameManagerState {
  final List<GameController> games;
  GameManagerState({this.games = const []});
  factory GameManagerState.initial() => GameManagerState();

  GameManagerState copyWith({List<GameController>? games}) => GameManagerState(games: games ?? this.games);
}
