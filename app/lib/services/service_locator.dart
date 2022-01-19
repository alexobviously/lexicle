import 'package:get_it/get_it.dart';
import 'package:word_game/services/dictionary.dart';

GetIt getIt = GetIt.I;

Dictionary dictionary() => getIt.get<Dictionary>();

Future<void> setUpServiceLocator() async {
  getIt.registerSingleton<Dictionary>(Dictionary());
}
