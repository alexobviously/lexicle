import 'package:common/common.dart';

abstract class Entity {
  final String id;
  final int timestamp;
  Entity({required this.id, required this.timestamp});
  Map<String, dynamic> export();

  static Map<Type, Function(Map<String, dynamic>)> builders = {
    Game: (doc) => Game.fromJson(doc),
    GameGroup: (doc) => GameGroup.fromJson(doc),
    User: (doc) => User.fromJson(doc),
    AuthData: (doc) => AuthData.fromJson(doc),
    UserStats: (doc) => UserStats.fromJson(doc),
    Team: (doc) => Team.fromJson(doc),
    Challenge: (doc) => Challenge.fromJson(doc),
  };

  static T build<T extends Entity>(Map<String, dynamic> doc) => builders[T]!(doc);

  static const Map<Type, String> entityTables = {
    Game: 'games',
    GameGroup: 'groups',
    User: 'users',
    AuthData: 'auth',
    UserStats: 'ustats',
    Team: 'teams',
    Challenge: 'challenges',
  };

  static String table(Type t) => entityTables[t] ?? '';
}
