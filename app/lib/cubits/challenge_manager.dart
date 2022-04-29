import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:word_game/mediator/online_mediator.dart';
import 'package:word_game/services/service_locator.dart';

class ChallengeManager extends Cubit<ChallengeManagerState> {
  ChallengeManager() : super(ChallengeManagerState.initial()) {
    refresh();
  }

  void refresh() async {
    await auth().ready; // because we want to submit the token if possible, for attempts
    Map<int, Challenge> challenges = {};
    for (int level in Challenges.allLevels) {
      final result = await db().getCurrentChallenge(level);
      if (result.ok) challenges[level] = result.object!;
    }
    emit(ChallengeManagerState(challenges: challenges));

    for (Challenge c in challenges.values) {
      if (c.hasAttempt) {
        getAttempt(c);
      }
    }
  }

  Future<void> getAttempt(Challenge challenge) async {
    if (!auth().loggedIn) return;
    final result = await db().getChallengeAttempt(auth().userId ?? '', challenge.id);
    if (!result.ok) return;
    Game game = result.object!;
    if (state.games.containsKey(challenge.id)) {
      state.games[challenge.id]!.emit(game);
    } else {
      GameController gc = GameController(game, OnlineMediator(gameId: game.id, wordLength: game.answer.length));
      Map<String, BaseGameController> games = Map.from(state.games);
      games[challenge.id] = gc;
      emit(state.copyWith(games: games));
    }
  }

  Future<Result<Challenge>> getChallenge({String? id, int? level, int? sequence}) async {
    if (id == null && level == null) return Result.error(Errors.invalidRequest);
    Challenge? challenge;
    if (id != null) {
      challenge = state.challengeWithId(id);
    } else if (sequence == null || sequence == state.challenges[level]?.sequence) {
      challenge = state.challenges[level];
    }
    Result<Challenge> result = Result.error(Errors.notFound);
    if (challenge == null) {
      if (id != null) {
        result = await db().get<Challenge>(id);
      } else if (sequence == null) {
        result = await db().getCurrentChallenge(level!);
      } else {
        result = await db().getChallenge(level!, sequence);
      }
      if (result.ok) challenge = result.object!;
    }
    if (challenge != null) {
      await getAttempt(challenge);
      return Result.ok(challenge);
    }
    return Result.error(result.error!);
  }
}

class ChallengeManagerState {
  final Map<int, Challenge> challenges;
  final Map<String, BaseGameController> games;

  Challenge? challengeWithId(String id) => challenges.values.firstWhereOrNull((e) => e.id == id);
  bool hasAttempt(String id) => games.containsKey(id);

  const ChallengeManagerState({this.challenges = const {}, this.games = const {}});
  factory ChallengeManagerState.initial() => ChallengeManagerState();

  ChallengeManagerState copyWith({
    Map<int, Challenge>? challenges,
    Map<String, BaseGameController>? games,
  }) =>
      ChallengeManagerState(
        challenges: challenges ?? this.challenges,
        games: games ?? this.games,
      );
}
