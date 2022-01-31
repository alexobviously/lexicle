import 'package:common/common.dart';

abstract class Entity {
  final String id;
  Entity({required this.id});
  Map<String, dynamic> export();

  static Map<Type, Function(Map<String, dynamic>)> entityBuilders = {
    Game: (doc) => Game.fromJson(doc),
    GameGroup: (doc) => GameGroup.fromJson(doc),
  };

  static const Map<Type, String> entityTables = {
    Game: 'games',
    GameGroup: 'groups',
  };

  static String table(Type t) => entityTables[t] ?? '';
}
