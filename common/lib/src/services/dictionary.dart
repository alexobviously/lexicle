import 'dart:math';
import 'package:common/common.dart';
import 'package:validators/validators.dart';

class Dictionary with ReadyManager {
  static const int minimumLength = 4;
  static const int maximumLength = 8;
  Map<int, List<String>> expanded = {};
  Map<int, List<String>> common = {};
  static int startTime = DateTime.now().millisecondsSinceEpoch;

  Dictionary() {
    init();
  }

  int get elapsed => DateTime.now().millisecondsSinceEpoch - startTime;

  @override
  Future<bool> initialise() async {
    clear();
    setReady();
    return true;
  }

  void clear() {
    for (int i = minimumLength; i <= maximumLength; i++) {
      expanded[i] = [];
      common[i] = [];
    }
  }

  Future<void> parseDictionary(String data, DictionaryType dict, [bool debug = false]) async {
    List<String> allWords = data.split('\n');
    if (debug) print('%% [${elapsed}ms] words split: ${allWords.length}');
    final _words = getDict(dict);
    for (String w in allWords) {
      if (w.length < minimumLength || w.length > maximumLength || !isAlpha(w)) continue;
      w = w.toLowerCase();
      _words[w.length]!.add(w);
      if (dict == DictionaryType.common) {
        if (!expanded[w.length]!.contains(w)) print('!!!!! word $w in common dict not found in expanded');
      }
    }
    if (debug) print('%% [${elapsed}ms] words sorted by length');
    for (int i = minimumLength; i <= maximumLength; i++) {
      if (debug) print('%%% $i: ${_words[i]!.length}');
    }
  }

  bool isValidWord(String word, [DictionaryType dict = DictionaryType.expanded]) {
    if (word.length < minimumLength || word.length > maximumLength) return false;
    return getDict(dict)[word.length]!.contains(word);
  }

  String randomWord(int length, {DictionaryType dict = DictionaryType.common, int? seed}) {
    int i = Random(seed).nextInt(getDict(dict)[length]!.length);
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
        return common;
      case DictionaryType.expanded:
        return expanded;
      default:
        throw ('Invalid dictionary type $dict');
    }
  }
}

enum DictionaryType {
  common,
  expanded,
}
