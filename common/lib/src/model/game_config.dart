import 'package:common/common.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';

part 'game_config.g.dart';

@CopyWith()
class GameConfig extends Equatable {
  final int wordLength;
  final int? timeLimit;

  const GameConfig({required this.wordLength, this.timeLimit});
  const GameConfig.initial() : this(wordLength: 5);

  factory GameConfig.fromJson(Map<String, dynamic> doc) => GameConfig(
        wordLength: doc[ConfigFields.wordLength],
        timeLimit: doc[ConfigFields.timeLimit],
      );

  Map<String, dynamic> toMap() => {
        ConfigFields.wordLength: wordLength,
        if (timeLimit != null) ConfigFields.timeLimit: timeLimit,
      };

  @override
  String toString() => 'GameConfig(length: $wordLength, timeLimit: $timeLimit)';

  @override
  List<Object?> get props => [wordLength, timeLimit];
}
