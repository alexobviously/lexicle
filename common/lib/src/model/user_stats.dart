// ignore_for_file: unnecessary_this

import 'package:common/common.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'user_stats.g.dart';

@CopyWith()
class UserStats implements Entity {
  @override
  final String id;
  final Map<int, int> numGroups;
  final Map<int, int> numGames;
  final Map<int, int> wins;
  final Map<int, Map<int, int>> guessCounts;
  final List<WordDifficulty> words;

  int get groupsTotal => numGroups.entries.fold(0, (a, b) => a + b.value);
  int get gamesTotal => numGames.entries.fold(0, (a, b) => a + b.value);
  int get winsTotal => wins.entries.fold(0, (a, b) => a + b.value);

  UserStats({
    String? id,
    this.numGroups = const {},
    this.numGames = const {},
    this.guessCounts = const {},
    this.words = const [],
    this.wins = const {},
  }) : this.id = id ?? ObjectId().id.hexString;

  factory UserStats.fromJson(Map<String, dynamic> doc) {
    // this is fucking cursed, I fucking hate this
    // three long ass lines for Map<String, Map<String, int>> => Map<int, Map<int, int>>
    final x = doc[StatsFields.guessCounts]
        .map<String, Map<String, dynamic>>((k, v) => MapEntry(k as String, v as Map<String, dynamic>));
    final y = intifyMapKeys<Map<String, dynamic>>(x);
    final z =
        y.map((k, v) => MapEntry<int, Map<int, int>>(k, v.map<int, int>((k2, v2) => MapEntry(int.parse(k2), v2))));

    return UserStats(
      id: doc[Fields.id],
      numGroups: intifyMapKeys(doc[StatsFields.numGroups].cast<String, int>()),
      numGames: intifyMapKeys(doc[StatsFields.numGames].cast<String, int>()),
      guessCounts: z,
      words: mapList<WordDifficulty>(doc[StatsFields.words] ?? [], (e) => WordDifficulty.fromJson(e)),
      wins: intifyMapKeys(doc[StatsFields.wins].cast<String, int>()),
    );
  }

  Map<String, dynamic> toMap() => {
        Fields.id: id,
        StatsFields.numGroups: stringifyMapKeys(numGroups),
        StatsFields.numGames: stringifyMapKeys(numGames),
        StatsFields.guessCounts: stringifyMapKeys(guessCounts.map((k, v) => MapEntry(k, stringifyMapKeys(v)))),
        StatsFields.words: words.map((e) => e.toMap()).toList(),
        StatsFields.wins: stringifyMapKeys(wins),
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
