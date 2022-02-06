import 'package:common/common.dart';
import 'package:common/src/model/user_stats.dart';

abstract class Entity {
  final String id;
  Entity({required this.id});
  Map<String, dynamic> export();

  static Map<Type, Function(Map<String, dynamic>)> builders = {
    Game: (doc) => Game.fromJson(doc),
    GameGroup: (doc) => GameGroup.fromJson(doc),
    User: (doc) => User.fromJson(doc),
    AuthData: (doc) => AuthData.fromJson(doc),
    UserStats: (doc) => UserStats.fromJson(doc),
  };

  static T build<T extends Entity>(Map<String, dynamic> doc) => builders[T]!(doc);

  static const Map<Type, String> entityTables = {
    Game: 'games',
    GameGroup: 'groups',
    User: 'users',
    AuthData: 'auth',
    UserStats: 'ustats',
  };

  static String table(Type t) => entityTables[t] ?? '';
}
