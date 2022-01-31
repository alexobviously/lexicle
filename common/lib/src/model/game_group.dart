import 'package:common/common.dart';
import 'package:common/src/model/standing.dart';
import 'package:copy_with_extension/copy_with_extension.dart';

part 'game_group.g.dart';

@CopyWith()
class GameGroup implements Entity {
  final String id;
  final String title;
  final GameConfig config;
  final String creator;
  final String? code;
  final int state;
  late final int created;

  /// A list of player IDs.
  final List<String> players;

  /// Map player IDs to their finalisd word. If they're not in here, they haven't picked yet.
  final Map<String, String> words;

  /// Map player IDs to all of the games they currently have.
  final Map<String, List<GameStub>> games;

  bool get started => state > MatchState.lobby;
  bool get finished => state >= MatchState.finished;
  bool get canBegin => state == MatchState.lobby && words.length == players.length && players.length > 1;
  Map<String, String> get hiddenWords => words.map((k, v) => MapEntry(k, '*' * v.length));
  bool playerReady(String id) => words.containsKey(id);
  Map<String, List<String>> get gameIds => games.map((k, v) => MapEntry(k, v.map((e) => e.id).toList()));

  double playerProgress(String player) =>
      games[player]?.fold<double>(0.0, (a, b) => a + (b.progress / games[player]!.length)) ?? 0.0;
  int playerGuesses(String player) => games[player]?.fold<int>(0, (a, b) => a + b.guesses) ?? 0;
  Map<String, int> get scores => games.map((k, v) => MapEntry(k, playerGuesses(k)));

  List<Standing>? _standings;
  List<Standing> get standings {
    if (_standings != null) return _standings!;
    _standings = players
        .map((e) => Standing(
              player: e,
              guesses: playerGuesses(e),
              progress: playerProgress(e),
            ))
        .toList();
    _standings!.sort((a, b) => a.orderWeight.compareTo(b.orderWeight));
    return _standings!;
  }

  /// Returns all of [player]'s GameStubs sorted by standing.
  /// Includes a blank GameStub at the position of the player.
  List<GameStub> playerGamesSorted(String player) {
    if (!games.containsKey(player)) return [];
    List<GameStub> _games = games[player]!;
    List<GameStub> _sorted = [];
    for (Standing s in standings) {
      String p = s.player;
      if (p == player) {
        _sorted.add(GameStub.blank());
      } else {
        _sorted.add(_games.firstWhereOrNull((e) => e.creator == p) ?? GameStub.blank());
      }
    }
    return _sorted;
  }

  double wordDifficulty(String player) {
    int total = 0;
    for (MapEntry<String, List<GameStub>> gl in games.entries) {
      if (gl.key == player) continue;
      GameStub? g = gl.value.firstWhereOrNull((e) => e.creator == player);
      if (g != null) total += g.guesses;
    }
    return total / (players.length - 1);
  }

  GameGroup({
    required this.id,
    required this.title,
    required this.config,
    required this.creator,
    this.code,
    this.state = MatchState.lobby,
    this.players = const [],
    this.words = const {},
    this.games = const {},
    int? created,
  }) : assert(players.contains(creator)) {
    this.created = created ?? DateTime.now().millisecondsSinceEpoch;
  }

  factory GameGroup.fromJson(Map<String, dynamic> doc) {
    return GameGroup(
      id: parseObjectId(doc[Fields.id])!,
      title: doc[GroupFields.title],
      config: GameConfig.fromJson(doc[GroupFields.config]),
      creator: doc[GroupFields.creator],
      code: doc[GroupFields.code],
      state: doc[GroupFields.state],
      players: coerceList<String>(doc[GroupFields.players] ?? []),
      words: (doc[GroupFields.words] ?? {}).map<String, String>((k, v) => MapEntry(k.toString(), v.toString())),
      games: {
        for (MapEntry entry in (doc[GroupFields.games] ?? {}).entries)
          entry.key: mapList<GameStub>(entry.value, (e) => GameStub.fromJson(e)),
      },
      created: doc[GroupFields.created],
    );
  }

  Map<String, dynamic> toMap({bool hideAnswers = false}) {
    return {
      Fields.id: parseObjectId(id),
      GroupFields.title: title,
      GroupFields.config: config.toMap(),
      GroupFields.creator: creator,
      if (code != null) GroupFields.code: code,
      GroupFields.state: state,
      GroupFields.players: players,
      GroupFields.words: hideAnswers ? hiddenWords : words,
      GroupFields.games: {
        for (MapEntry<String, List<GameStub>> entry in games.entries)
          entry.key: mapList<Map<String, dynamic>>(entry.value, (e) => e.toMap()),
      },
      GroupFields.created: created,
    };
  }

  @override
  Map<String, dynamic> export() => toMap();

  GameGroup updateGameStub(String player, GameStub stub) {
    Map<String, List<GameStub>> _games = Map.from(games);
    if (!_games.containsKey(player)) _games[player] = [];
    _games[player]!.removeWhere((e) => e.id == stub.id);
    _games[player]!.add(stub);
    return copyWith(games: _games);
  }

  @override
  String toString() => 'GameGroup($id, title: $title, state: $state)';
}

class MatchState {
  static const int loading = -1; // used in the app when waiting for server
  static const int lobby = 0;
  static const int playing = 1;
  static const int finished = 2;
}
