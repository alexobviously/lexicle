import 'package:common/common.dart';
import 'package:copy_with_extension/copy_with_extension.dart';

part 'auth_data.g.dart';

@CopyWith()
class AuthData implements Entity {
  @override
  final String id;
  final String? password;

  AuthData({required this.id, this.password});

  factory AuthData.fromJson(Map<String, dynamic> doc) => AuthData(
        id: doc[Fields.id],
        password: doc[UserFields.password],
      );

  Map<String, dynamic> toMap() => {
        Fields.id: id,
        if (password != null) UserFields.password: password,
      };

  @override
  Map<String, dynamic> export() => toMap();
}
