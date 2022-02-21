// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension UserStatsCopyWith on UserStats {
  UserStats copyWith({
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
