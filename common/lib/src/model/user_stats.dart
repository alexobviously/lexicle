import 'package:common/common.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'user_stats.g.dart';

@CopyWith()
class UserStats implements Entity {
  @override
  final String id;
  @override
  final int timestamp;
  final Map<int, int> numGroups;
  final Map<int, int> numGames;
  final Map<int, int> wins;
  final Map<int, Map<int, int>> guessCounts;
  final Map<int, int> timeouts;
  final List<WordDifficulty> words;
  final Map<int, ChallengeStats> challengeStats;

  int get groupsTotal => numGroups.entries.fold(0, (a, b) => a + b.value);
  int get gamesTotal => numGames.entries.fold(0, (a, b) => a + b.value);
  int get winsTotal => wins.entries.fold(0, (a, b) => a + b.value);
  bool hasChallengeStats(int level) => challengeStats.containsKey(level);

  UserStats({
    String? id,
    int? timestamp,
    this.numGroups = const {},
    this.numGames = const {},
    this.guessCounts = const {},
    this.words = const [],
    this.wins = const {},
    this.timeouts = const {},
    this.challengeStats = const {},
  })  : id = id ?? ObjectId().id.hexString,
        timestamp = timestamp ?? nowMs();

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
      timestamp: doc[Fields.timestamp] ?? nowMs(),
      numGroups: intifyMapKeys(doc[StatsFields.numGroups].cast<String, int>()),
      numGames: intifyMapKeys(doc[StatsFields.numGames].cast<String, int>()),
      guessCounts: z,
      words: mapList<WordDifficulty>(doc[StatsFields.words] ?? [], (e) => WordDifficulty.fromJson(e)),
      wins: intifyMapKeys(doc[StatsFields.wins].cast<String, int>()),
      timeouts: intifyMapKeys((doc[StatsFields.timeouts] ?? {}).cast<String, int>()),
      // TODO: I can't be bothered testing this rn
      challengeStats: (doc[StatsFields.challengeStats] ?? {}).cast<String, dynamic>().map<int, ChallengeStats>(
          (k, v) => MapEntry(int.parse(k), ChallengeStats.fromJson(v as Map<String, dynamic>))),
    );
  }

  Map<String, dynamic> toMap({bool includeTimestamp = false}) => {
        Fields.id: id,
        if (includeTimestamp) Fields.timestamp: timestamp,
        StatsFields.numGroups: stringifyMapKeys(numGroups),
        StatsFields.numGames: stringifyMapKeys(numGames),
        StatsFields.guessCounts: stringifyMapKeys(guessCounts.map((k, v) => MapEntry(k, stringifyMapKeys(v)))),
        StatsFields.words: words.map((e) => e.toMap()).toList(),
        StatsFields.wins: stringifyMapKeys(wins),
        StatsFields.timeouts: stringifyMapKeys(timeouts),
        StatsFields.challengeStats: stringifyMapKeys(challengeStats.map((k, v) => MapEntry(k, v.toMap()))),
      };

  @override
  Map<String, dynamic> export() => toMap(includeTimestamp: true);
}

class WordDifficulty {
  final String word;
  final double difficulty;
  WordDifficulty(this.word, this.difficulty);

  factory WordDifficulty.fromJson(Map<String, dynamic> doc) =>
      WordDifficulty(doc[WordFields.content], doc[WordFields.difficulty]);

  Map<String, dynamic> toMap() => {WordFields.content: word, WordFields.difficulty: difficulty};
}

@CopyWith()
class ChallengeStats {
  final int level;
  final int? lastCompleted;
  final Map<int, int> guessCounts;
  final int bestStreak;
  final int streak;
  final int streakExpiry;

  int get currentStreak => streakExpiry > nowMs() ? streak : 0;

  ChallengeStats({
    required this.level,
    this.lastCompleted,
    this.guessCounts = const {},
    this.bestStreak = 0,
    this.streak = 0,
    int? streakExpiry,
  }) : streakExpiry = streakExpiry ?? nowMs();

  factory ChallengeStats.fromJson(Map<String, dynamic> doc) => ChallengeStats(
        level: doc[ChallengeFields.level],
        lastCompleted: doc[StatsFields.lastCompleted],
        guessCounts: intifyMapKeys(doc[StatsFields.guessCounts].cast<String, int>()),
        bestStreak: doc[StatsFields.bestStreak],
        streak: doc[StatsFields.streak],
        streakExpiry: doc[StatsFields.streakExpiry],
      );

  Map<String, dynamic> toMap() => {
        ChallengeFields.level: level,
        StatsFields.lastCompleted: lastCompleted,
        StatsFields.guessCounts: stringifyMapKeys(guessCounts),
        StatsFields.bestStreak: bestStreak,
        StatsFields.streak: streak,
        StatsFields.streakExpiry: streakExpiry,
      };
}
