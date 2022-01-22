import 'dart:math';

import 'package:flutter/services.dart';
import 'package:validators/validators.dart';
import 'package:word_game/extensions/ready_mixin.dart';

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
    await loadDictionary('assets/words_alpha.txt', DictionaryType.expanded);
    await loadDictionary('assets/words_common.txt', DictionaryType.common);
    setReady();
    return true;
  }

  Future<void> loadDictionary(String path, DictionaryType dict) async {
    print('%% [${elapsed}ms] loading dictionary ${dict.name}');
    String everything = await rootBundle.loadString(path);
    print('%% [${elapsed}ms] dict file loaded: ${everything.substring(0, 50)}...');
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

  Iterable<String> getSuggestions(
    String start,
    int length, {
    int limit = 30,
    DictionaryType dict = DictionaryType.expanded,
  }) {
    assert(length >= minimumLength && length <= maximumLength, 'Invalid length');
    final _all = getDict(dict)[length]!;
    return _all.where((e) => e.startsWith(start)).take(limit);
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
