// ignore_for_file: unnecessary_this

import 'package:common/common.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'user.g.dart';

@CopyWith()
class User implements Entity {
  @override
  final String id;
  final String username;
  final Rating rating;

  User({
    String? id,
    required this.username,
    required this.rating,
  }) : this.id = id ?? ObjectId().id.hexString;

  factory User.fromJson(Map<String, dynamic> doc) {
    return User(
      id: doc[Fields.id],
      username: doc[UserFields.username],
      rating: doc[UserFields.rating] != null ? Rating.fromJson(doc[UserFields.rating]) : Rating.initial(),
    );
  }

  Map<String, dynamic> toMap() => {
        Fields.id: id,
        UserFields.username: username,
        UserFields.rating: rating.toMap(),
      };

  @override
  Map<String, dynamic> export() => toMap();
}
