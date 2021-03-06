// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_group.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension GameGroupCopyWith on GameGroup {
  GameGroup copyWith({
    String? code,
    GameConfig? config,
    String? creator,
    int? endTime,
    Map<String, List<GameStub>>? games,
    String? id,
    List<String>? players,
    int? state,
    int? timestamp,
    String? title,
    Map<String, String>? words,
  }) {
    return GameGroup(
      code: code ?? this.code,
      config: config ?? this.config,
      creator: creator ?? this.creator,
      endTime: endTime ?? this.endTime,
      games: games ?? this.games,
      id: id ?? this.id,
      players: players ?? this.players,
      state: state ?? this.state,
      timestamp: timestamp ?? this.timestamp,
      title: title ?? this.title,
      words: words ?? this.words,
    );
  }
}
