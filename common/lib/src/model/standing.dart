import 'package:common/common.dart';
import 'package:copy_with_extension/copy_with_extension.dart';

part 'standing.g.dart';

/// The standing of a player within a group.
@CopyWith()
class Standing {
  /// id of the player.
  final String player;

  /// Total number of guesses made across all games.
  final int guesses;

  /// Progress in finishing all the games.
  final double progress;

  bool get finished => progress >= 1.0;
  double get orderWeight => guesses == 0 ? 999999 : (1 / (progress + 0.0001)) * guesses;

  Standing({
    required this.player,
    this.guesses = 0,
    this.progress = 0.0,
  });
  factory Standing.initial(String player) => Standing(player: player);

  factory Standing.fromJson(Map<String, dynamic> doc) => Standing(
        player: doc[StubFields.player],
        progress: doc[StubFields.progress],
        guesses: doc[StubFields.guesses],
      );

  Map<String, dynamic> toMap() => {
        StubFields.player: player,
        StubFields.progress: progress,
        StubFields.guesses: guesses,
      };

  @override
  String toString() => 'Standing($player, progress: $progress, guesses: $guesses)';
}
