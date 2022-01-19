import 'dart:io';
import 'dart:math';

import 'package:validators/validators.dart';
import '../extensions/ready_mixin.dart';

class Dictionary with ReadyManager {
  static const int minimumLength = 4;
  static const int maximumLength = 8;
  Map<int, List<String>> words = {};
  Map<int, List<String>> commonWords = {};
  static int startTime = DateTime.now().millisecondsSinceEpoch;

  Dictionary() {
    init();
  }

  int get elapsed => DateTime.now().millisecondsSinceEpoch - startTime;

  @override
  Future<bool> initialise() async {
    for (int i = minimumLength; i <= maximumLength; i++) {
      words[i] = [];
      commonWords[i] = [];
    }
    await loadDictionary('dictionary/words_alpha.txt', DictionaryType.expanded);
    await loadDictionary('dictionary/words_common.txt', DictionaryType.common);
    setReady();
    return true;
  }

  Future<void> loadDictionary(String path, DictionaryType dict) async {
    print('%% [${elapsed}ms] loading dictionary ${dict.name}');
    String _folder = Directory.current.path;
    final _file = File('$_folder/$path');
    String everything = await _file.readAsString();
    List<String> allWords = everything.split('\n');
    print('%% [${elapsed}ms] words split: ${allWords.length}');
    final _words = getDict(dict);
    for (String w in allWords) {
      if (w.length < minimumLength || w.length > maximumLength || !isAlpha(w)) continue;
      w = w.toLowerCase();
      _words[w.length]!.add(w);
      if (dict == DictionaryType.common) {
        if (!words[w.length]!.contains(w)) print('!!!!! word $w in common dict not found in expanded');
      }
    }
    print('%% [${elapsed}ms] words sorted by length');
    for (int i = minimumLength; i <= maximumLength; i++) {
      print('%%% $i: ${_words[i]!.length}');
    }
  }

  bool isValidWord(String word, [DictionaryType dict = DictionaryType.expanded]) {
    if (word.length < minimumLength || word.length > maximumLength) return false;
    return getDict(dict)[word.length]!.contains(word);
  }

  String randomWord(int length, [DictionaryType dict = DictionaryType.common]) {
    int i = Random().nextInt(getDict(dict)[length]!.length);
    return getDict(dict)[length]![i];
  }

  Map<int, List<String>> getDict(DictionaryType dict) {
    switch (dict) {
      case DictionaryType.common:
        return commonWords;
      case DictionaryType.expanded:
        return words;
      default:
        throw ('Invalid dictionary type $dict');
    }
  }
}

enum DictionaryType {
  common,
  expanded,
}
