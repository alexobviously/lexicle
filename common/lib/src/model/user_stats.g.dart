// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension UserStatsCopyWith on UserStats {
  UserStats copyWith({
    Map<int, ChallengeStats>? challengeStats,
    Map<int, Map<int, int>>? guessCounts,
    String? id,
    Map<int, int>? numGames,
    Map<int, int>? numGroups,
    Map<int, int>? timeouts,
    int? timestamp,
    Map<int, int>? wins,
    List<WordDifficulty>? words,
  }) {
    return UserStats(
      challengeStats: challengeStats ?? this.challengeStats,
      guessCounts: guessCounts ?? this.guessCounts,
      id: id ?? this.id,
      numGames: numGames ?? this.numGames,
      numGroups: numGroups ?? this.numGroups,
      timeouts: timeouts ?? this.timeouts,
      timestamp: timestamp ?? this.timestamp,
      wins: wins ?? this.wins,
      words: words ?? this.words,
    );
  }
}

extension ChallengeStatsCopyWith on ChallengeStats {
  ChallengeStats copyWith({
    int? bestStreak,
    Map<int, int>? guessCounts,
    int? lastCompleted,
    int? level,
    int? streak,
    int? streakExpiry,
  }) {
    return ChallengeStats(
      bestStreak: bestStreak ?? this.bestStreak,
      guessCounts: guessCounts ?? this.guessCounts,
      lastCompleted: lastCompleted ?? this.lastCompleted,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      streakExpiry: streakExpiry ?? this.streakExpiry,
    );
  }
}
