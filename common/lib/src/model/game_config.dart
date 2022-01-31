import 'package:common/common.dart';
import 'package:copy_with_extension/copy_with_extension.dart';

part 'game_config.g.dart';

@CopyWith()
class GameConfig {
  final int wordLength;

  const GameConfig({required this.wordLength});
  GameConfig.initial() : this(wordLength: 5);

  factory GameConfig.fromJson(Map<String, dynamic> doc) => GameConfig(
        wordLength: doc[ConfigFields.wordLength],
      );

  Map<String, dynamic> toMap() => {
        ConfigFields.wordLength: wordLength,
      };

  @override
  String toString() => 'GameConfig(length: $wordLength)';
}
