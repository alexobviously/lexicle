// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rush.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension RushCopyWith on Rush {
  Rush copyWith({
    List<Game>? completed,
    GameConfig? config,
    Game? current,
    int? endReason,
    String? id,
    int? startTime,
    int? timeAdjustment,
    int? timestamp,
  }) {
    return Rush(
      completed: completed ?? this.completed,
      config: config ?? this.config,
      current: current ?? this.current,
      endReason: endReason ?? this.endReason,
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      timeAdjustment: timeAdjustment ?? this.timeAdjustment,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
