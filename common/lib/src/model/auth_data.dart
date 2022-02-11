import 'package:common/common.dart';
import 'package:copy_with_extension/copy_with_extension.dart';

part 'auth_data.g.dart';

@CopyWith()
class AuthData implements Entity {
  @override
  final String id;
  @override
  final int timestamp;
  final String? password;

  AuthData({
    required this.id,
    int? timestamp,
    this.password,
  }) : timestamp = timestamp ?? nowMs();

  factory AuthData.fromJson(Map<String, dynamic> doc) => AuthData(
        id: doc[Fields.id],
        timestamp: doc[Fields.timestamp] ?? nowMs(),
        password: doc[UserFields.password],
      );

  Map<String, dynamic> toMap({bool includeTimestamp = false}) => {
        Fields.id: id,
        if (includeTimestamp) Fields.timestamp: timestamp,
        if (password != null) UserFields.password: password,
      };

  @override
  Map<String, dynamic> export() => toMap(includeTimestamp: true);
}
