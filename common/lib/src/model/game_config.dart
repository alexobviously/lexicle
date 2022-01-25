import 'package:copy_with_extension/copy_with_extension.dart';

part 'game_config.g.dart';

@CopyWith()
class GameConfig {
  final int wordLength;

  const GameConfig({required this.wordLength});
  GameConfig.initial() : this(wordLength: 5);

  static const __wordLength = 'l';

  factory GameConfig.fromJson(Map<String, dynamic> doc) => GameConfig(
        wordLength: doc[__wordLength],
      );

  Map<String, dynamic> toMap() => {
        __wordLength: wordLength,
      };

  @override
  String toString() => 'GameConfig(length: $wordLength)';
}
