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

  User({
    String? id,
    required this.username,
  }) : this.id = id ?? ObjectId().id.hexString;

  factory User.fromJson(Map<String, dynamic> doc) {
    return User(
      id: doc[Fields.id],
      username: doc[UserFields.username],
    );
  }

  Map<String, dynamic> toMap() => {
        Fields.id: id,
        UserFields.username: username,
      };

  @override
  Map<String, dynamic> export() => toMap();
}
