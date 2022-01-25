import 'package:common/common.dart';
import 'package:copy_with_extension/copy_with_extension.dart';

part 'game_group.g.dart';

@CopyWith()
class GameGroup {
  final String id;
  final String title;
  final GameConfig config;
  final String creator;
  final String? code;
  final int state;

  /// A list of player IDs.
  final List<String> players;

  /// Map player IDs to their finalisd word. If they're not in here, they haven't picked yet.
  final Map<String, String> words;

  /// Map player IDs to all of the games they currently have.
  final Map<String, List<String>> games;

  bool get canBegin => state == MatchState.lobby && words.length == players.length && players.length > 1;
  Map<String, String> get hiddenWords => words.map((k, v) => MapEntry(k, '*' * v.length));
  bool playerReady(String id) => words.containsKey(id);

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
  }) : assert(players.contains(creator));

  static const String __id = 'id';
  static const String __title = 't';
  static const String __config = 'c';
  static const String __creator = 'x';
  static const String __code = 'q';
  static const String __state = 's';
  static const String __players = 'p';
  static const String __words = 'w';
  static const String __games = 'g';

  factory GameGroup.fromJson(Map<String, dynamic> doc) {
    return GameGroup(
      id: parseObjectId(doc[__id])!,
      title: doc[__title],
      config: GameConfig.fromJson(doc[__config]),
      creator: doc[__creator],
      code: doc[__code],
      state: doc[__state],
      players: coerceList<String>(doc[__players] ?? []),
      words: (doc[__words] ?? {}).map<String, String>((k, v) => MapEntry(k.toString(), v.toString())),
      games: {
        for (MapEntry entry in (doc[__games] ?? {}).entries) entry.key: coerceList<String>(entry.value),
      },
    );
  }

  Map<String, dynamic> toMap({bool hideAnswers = false}) {
    return {
      __id: parseObjectId(id),
      __title: title,
      __config: config.toMap(),
      __creator: creator,
      if (code != null) __code: code,
      __state: state,
      __players: players,
      __words: hideAnswers ? hiddenWords : words,
      __games: games,
    };
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
