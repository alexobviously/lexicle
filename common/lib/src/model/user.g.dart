// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension UserCopyWith on User {
  User copyWith({
    String? id,
    int? permissions,
    Rating? rating,
    String? team,
    int? timestamp,
    String? username,
  }) {
    return User(
      id: id ?? this.id,
      permissions: permissions ?? this.permissions,
      rating: rating ?? this.rating,
      team: team ?? this.team,
      timestamp: timestamp ?? this.timestamp,
      username: username ?? this.username,
    );
  }

  User copyWithNull({
    bool id = false,
    bool rating = false,
    bool team = false,
    bool timestamp = false,
  }) {
    return User(
      id: id == true ? null : this.id,
      permissions: permissions,
      rating: rating == true ? null : this.rating,
      team: team == true ? null : this.team,
      timestamp: timestamp == true ? null : this.timestamp,
      username: username,
    );
  }
}
