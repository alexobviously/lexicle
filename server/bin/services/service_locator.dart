import 'package:get_it/get_it.dart';
import 'dictionary.dart';

GetIt getIt = GetIt.I;

Dictionary dictionary() => getIt.get<Dictionary>();

Future<void> setUpServiceLocator() async {
  getIt.registerSingleton<Dictionary>(Dictionary());
}
