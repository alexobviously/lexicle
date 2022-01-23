import 'package:common/common.dart';
import 'package:flutter/services.dart';

class AppDictionary extends Dictionary {
  AppDictionary() {
    init();
  }

  @override
  Future<bool> initialise() async {
    clear();
    await loadDictionary('assets/words_alpha.txt', DictionaryType.expanded);
    await loadDictionary('assets/words_common.txt', DictionaryType.common);
    setReady();
    return true;
  }

  Future<void> loadDictionary(String path, DictionaryType dict) async {
    print('%% [${elapsed}ms] loading dictionary ${dict.name}');
    String data = await rootBundle.loadString(path);
    print('%% [${elapsed}ms] dict file loaded: ${data.substring(0, 50)}...');
    parseDictionary(data, dict);
  }
}
