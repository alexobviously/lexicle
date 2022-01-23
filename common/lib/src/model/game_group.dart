import 'package:copy_with_extension/copy_with_extension.dart';

part 'game_group.g.dart';

@CopyWith()
class GameGroup {
  final String id;
  final int state;
  final List<String> players;
  final Map<String, List<String>> games;

  GameGroup({
    required this.id,
    this.state = MatchState.lobby,
    this.players = const [],
    this.games = const {},
  });
}

class MatchState {
  static const int lobby = 0;
  static const int playing = 1;
  static const int finished = 2;
}
