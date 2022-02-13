import 'package:common/common.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'user.g.dart';

@CopyWith(generateCopyWithNull: true)
class User implements Entity {
  @override
  final String id;
  @override
  final int timestamp;
  final String username;
  final Rating rating;
  final String? team;
  final int permissions;

  bool get isAdmin => permissions > 0;

  User({
    String? id,
    int? timestamp,
    required this.username,
    Rating? rating,
    this.team,
    this.permissions = 0,
  })  : id = id ?? ObjectId().id.hexString,
        timestamp = timestamp ?? nowMs(),
        rating = rating ?? Rating.initial();

  factory User.fromJson(Map<String, dynamic> doc) {
    return User(
      id: doc[Fields.id],
      timestamp: doc[Fields.timestamp] ?? nowMs(),
      username: doc[UserFields.username],
      rating: doc[UserFields.rating] != null ? Rating.fromJson(doc[UserFields.rating]) : Rating.initial(),
      team: doc[UserFields.team],
      permissions: doc[UserFields.permissions] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        Fields.id: id,
        Fields.timestamp: timestamp,
        UserFields.username: username,
        UserFields.rating: rating.toMap(),
        if (team != null) UserFields.team: team,
        UserFields.permissions: permissions,
      };

  @override
  Map<String, dynamic> export() => toMap();

  @override
  String toString() => 'User($id, $username, $rating)';
}
