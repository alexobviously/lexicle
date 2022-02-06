import 'package:common/common.dart';
import 'package:copy_with_extension/copy_with_extension.dart';

part 'user_stats.g.dart';

@CopyWith()
class UserStats implements Entity {
  @override
  final String id;
  final Map<int, int> numGroups;
  final Map<int, int> numGames;
  final Map<int, Map<int, int>> guessCounts;
  final List<WordDifficulty> words;

  int get groupsTotal => numGroups.entries.fold(0, (a, b) => a + b.value);
  int get gamesTotal => numGames.entries.fold(0, (a, b) => a + b.value);

  UserStats({
    required this.id,
    this.numGroups = const {},
    this.numGames = const {},
    this.guessCounts = const {},
    this.words = const [],
  });

  factory UserStats.fromJson(Map<String, dynamic> doc) {
    return UserStats(
      id: doc[Fields.id],
      numGroups: doc[StatsFields.numGroups],
      numGames: doc[StatsFields.numGames],
      guessCounts: doc[StatsFields.guessCounts],
      words: doc[StatsFields.words],
    );
  }

  Map<String, dynamic> toMap() => {
        Fields.id: id,
        StatsFields.numGroups: numGroups,
        StatsFields.numGames: numGames,
        StatsFields.guessCounts: guessCounts,
        StatsFields.words: words,
      };

  @override
  Map<String, dynamic> export() => toMap();
}

class WordDifficulty {
  final String word;
  final double difficulty;
  WordDifficulty(this.word, this.difficulty);

  factory WordDifficulty.fromJson(Map<String, dynamic> doc) =>
      WordDifficulty(doc[WordFields.content], doc[WordFields.difficulty]);

  Map<String, dynamic> toMap() => {WordFields.content: word, WordFields.difficulty: difficulty};
}
