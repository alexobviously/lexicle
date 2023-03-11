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
    String unwrap(String title, Result<Iterable<String>> result) {
      String r = result.ok ? result.object!.length.toString() : 'Error: ${result.error}';
      return ('::::: $title: $r');
    }

    int total = gameStore().cache.length +
        groupStore().cache.length +
        userStore().cache.length +
        authStore().cache.length +
        ustatsStore().cache.length +
        teamStore().cache.length;

    if (total < 1) return;

    print(':::::::::::::::::::::::::::::::');
    print('[Cache Manager]: pushing caches');
    final games = await gameStore().pushCache();
    final groups = await groupStore().pushCache();
    final users = await userStore().pushCache();
    final auths = await authStore().pushCache();
    final ustats = await ustatsStore().pushCache();
    final teams = await teamStore().pushCache();
    print('[Cache Manager]: finished');
    print(unwrap('Games', games));
    print(unwrap('Groups', groups));
    print(unwrap('Users', users));
    print(unwrap('Auths', auths));
    print(unwrap('User Stats', ustats));
    print(unwrap('Teams', teams));
    print(':::::::::::::::::::::::::::::::');
  }
}
