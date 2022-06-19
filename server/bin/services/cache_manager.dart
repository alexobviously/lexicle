import 'dart:async';

import 'package:common/common.dart';

import 'service_locator.dart';

/// Really simple thing for now that just forces stores to push
/// their caches every few minutes.
class CacheManager {
  final Duration interval;
  CacheManager({this.interval = const Duration(minutes: 5)}) {
    init();
  }

  void init() {
    Timer.periodic(interval, (_) => pushCaches());
  }

  void pushCaches() async {
    String _unwrap(String title, Result<Iterable<String>> result) {
      String r = result.ok ? result.object!.length.toString() : 'Error: ${result.error}';
      return ('::::: $title: $r');
    }

    print(':::::::::::::::::::::::::::::::');
    print('[Cache Manager]: pushing caches');
    final _games = await gameStore().pushCache();
    final _groups = await groupStore().pushCache();
    final _users = await userStore().pushCache();
    final _auths = await authStore().pushCache();
    final _ustats = await ustatsStore().pushCache();
    final _teams = await teamStore().pushCache();
    print('[Cache Manager]: finished');
    print(_unwrap('Games', _games));
    print(_unwrap('Groups', _groups));
    print(_unwrap('Users', _users));
    print(_unwrap('User Stats', _ustats));
    print(_unwrap('Teams', _teams));
    print(':::::::::::::::::::::::::::::::');
  }
}
