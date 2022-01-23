import 'package:get_it/get_it.dart';
import 'package:word_game/services/app_dictionary.dart';

GetIt getIt = GetIt.I;

AppDictionary dictionary() => getIt.get<AppDictionary>();

Future<void> setUpServiceLocator() async {
  getIt.registerSingleton<AppDictionary>(AppDictionary());
}
