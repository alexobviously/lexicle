import 'package:get_it/get_it.dart';
import '../gameserver/game_server.dart';
import 'dictionary.dart';
import 'environment.dart';

GetIt getIt = GetIt.I;

ServerDictionary dictionary() => getIt.get<ServerDictionary>();
GameServer gameServer() => getIt.get<GameServer>();

Future<void> setUpServiceLocator({required Environment environment}) async {
  getIt.registerSingleton<ServerDictionary>(ServerDictionary());
  getIt.registerSingleton<GameServer>(GameServer());
  getIt.registerSingleton<Environment>(environment);
}
