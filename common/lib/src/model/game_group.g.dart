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
    Map<String, List<String>>? games,
    String? id,
    List<String>? players,
    int? state,
    String? title,
    Map<String, String>? words,
  }) {
    return GameGroup(
      code: code ?? this.code,
      config: config ?? this.config,
      creator: creator ?? this.creator,
      games: games ?? this.games,
      id: id ?? this.id,
      players: players ?? this.players,
      state: state ?? this.state,
      title: title ?? this.title,
      words: words ?? this.words,
    );
  }
}
