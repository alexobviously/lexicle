import 'dart:io';
import 'package:common/common.dart';

class ServerDictionary extends Dictionary {
  ServerDictionary();

  @override
  Future<bool> initialise() async {
    clear();
    await loadDictionary('dictionary/words_alpha.txt', DictionaryType.expanded);
    await loadDictionary('dictionary/words_common.txt', DictionaryType.common);
    setReady();
    return true;
  }

  Future<void> loadDictionary(String path, DictionaryType dict) async {
    // print('%% [${elapsed}ms] loading dictionary ${dict.name}');
    String folder = Directory.current.path;
    final file = File('$folder/$path');
    String data = await file.readAsString();
    parseDictionary(data, dict);
  }
}
