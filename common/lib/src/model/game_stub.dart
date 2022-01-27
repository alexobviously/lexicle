import 'package:copy_with_extension/copy_with_extension.dart';

part 'game_stub.g.dart';

/// A stub that contains the basic status of the game, to be included with GameGroup.
@CopyWith()
class GameStub {
  /// id of the game.
  final String id;

  /// Approximate progress from 0-1.
  final double progress;

  /// Number of guesses made so far
  final int guesses;

  bool get finished => progress >= 1.0;

  const GameStub({required this.id, this.progress = 0.0, this.guesses = 0});
  factory GameStub.initial(String id) => GameStub(id: id);
  factory GameStub.blank() => GameStub(id: '');

  static const __id = 'id';
  static const __progress = 'p';
  static const __guesses = 'g';

  factory GameStub.fromJson(Map<String, dynamic> doc) => GameStub(
        id: doc[__id],
        progress: doc[__progress],
        guesses: doc[__guesses],
      );

  Map<String, dynamic> toMap() => {
        __id: id,
        __progress: progress,
        __guesses: guesses,
      };

  @override
  String toString() => 'GameStub($id, progress: $progress, guesses: $guesses)';
}
