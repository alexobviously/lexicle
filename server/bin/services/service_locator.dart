import 'package:get_it/get_it.dart';
import 'dictionary.dart';

GetIt getIt = GetIt.I;

ServerDictionary dictionary() => getIt.get<ServerDictionary>();

Future<void> setUpServiceLocator() async {
  getIt.registerSingleton<ServerDictionary>(ServerDictionary());
}
