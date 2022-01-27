import 'package:mongo_dart/mongo_dart.dart';

List<T> coerceList<T>(List<dynamic> list) => list.map((e) => e as T).toList();
List<T> mapList<T>(List<dynamic> list, T Function(dynamic) m) => list.map((e) => m(e)).toList();
String? parseObjectId(dynamic id) {
  if (id is String) return id;
  if (id is ObjectId) return id.id.hexString;
  return null;
}
