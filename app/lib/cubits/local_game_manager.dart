import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:word_game/mediator/offline_mediator.dart';
import 'package:word_game/services/service_locator.dart';

class LocalGameManager extends Cubit<LocalGameManagerState> {
  LocalGameManager() : super(LocalGameManagerState.initial());

  void createGame(GameConfig config) {
    final answer = dictionary().randomWord(config.wordLength);
    final mediator = OfflineMediator(answer: answer);

    int? endTime = config.timeLimit != null
        ? DateTime.now()
              .add(Duration(milliseconds: config.timeLimit!))
              .millisecondsSinceEpoch
        : null;

    final gc = GameController.initial(
      player: 'player',
      length: config.wordLength,
      mediator: mediator,
      endTime: endTime,
    );

    final games = [...state.games, gc];

    emit(state.copyWith(games: games));
  }

  void removeGame(String id) {
    int index = state.games.indexWhere((e) => e.state.id == id);
    if (index == -1) return;

    List<GameController> games = List.from(state.games);
    games.removeAt(index);
    emit(state.copyWith(games: games));
  }

  Stream<int> get numGamesStream =>
      stream.map((e) => e.games.length).distinct();
}

class LocalGameManagerState {
  final List<GameController> games;
  LocalGameManagerState({this.games = const []});
  factory LocalGameManagerState.initial() => LocalGameManagerState();

  LocalGameManagerState copyWith({List<GameController>? games}) =>
      LocalGameManagerState(games: games ?? this.games);
}
