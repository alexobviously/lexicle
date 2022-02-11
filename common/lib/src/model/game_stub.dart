import 'package:common/common.dart';
import 'package:copy_with_extension/copy_with_extension.dart';

part 'game_stub.g.dart';

/// A stub that contains the basic status of the game, to be included with GameGroup.
@CopyWith()
class GameStub {
  /// id of the game.
  final String id;

  /// Approximate progress from 0-1.
  final double progress;

  /// Number of guesses made so far.
  final int guesses;

  /// The creator of the game (user id).
  final String creator;

  final int? endReason;

  bool get finished => progress >= 1.0;

  const GameStub({
    required this.id,
    this.progress = 0.0,
    this.guesses = 0,
    required this.creator,
    this.endReason,
  });
  factory GameStub.initial(String id, String creator) => GameStub(id: id, creator: creator);
  factory GameStub.blank() => GameStub(id: '', creator: '');

  factory GameStub.fromJson(Map<String, dynamic> doc) => GameStub(
        id: doc[Fields.id],
        progress: doc[StubFields.progress],
        guesses: doc[StubFields.guesses],
        creator: doc[StubFields.creator],
        endReason: doc[StubFields.endReason],
      );

  Map<String, dynamic> toMap() => {
        Fields.id: id,
        StubFields.progress: progress,
        StubFields.guesses: guesses,
        StubFields.creator: creator,
        if (endReason != null) StubFields.endReason: endReason,
      };

  @override
  String toString() => 'GameStub($id, progress: $progress, guesses: $guesses, creator: $creator)';
}
