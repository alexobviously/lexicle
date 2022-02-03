import 'package:common/common.dart';
import 'package:common/src/model/auth_data.dart';
import 'package:copy_with_extension/copy_with_extension.dart';

@CopyWith()
class User implements Entity {
  @override
  final String id;
  final String username;

  User({required this.id, required this.username});

  factory User.fromJson(Map<String, dynamic> doc) {
    return User(
      id: doc[Fields.id],
      username: UserFields.username,
    );
  }

  Map<String, dynamic> toMap() => {
        Fields.id: id,
        UserFields.username: username,
      };

  @override
  Map<String, dynamic> export() => toMap();
}
