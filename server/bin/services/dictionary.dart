import 'dart:io';
import 'package:common/common.dart';

class ServerDictionary extends Dictionary {
  ServerDictionary() {
    init();
  }

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
    String _folder = Directory.current.path;
    final _file = File('$_folder/$path');
    String data = await _file.readAsString();
    parseDictionary(data, dict);
  }
}
