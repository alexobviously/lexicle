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

  bool get canBegin => games.length == players.length && players.length > 1;

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
  });
}

class MatchState {
  static const int lobby = 0;
  static const int playing = 1;
  static const int finished = 2;
}
