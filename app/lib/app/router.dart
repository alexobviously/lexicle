import 'package:go_router/go_router.dart';
import 'package:word_game/views/about_view.dart';
import 'package:word_game/views/auth/auth_view.dart';
import 'package:word_game/views/dict_search_view.dart';
import 'package:word_game/views/groups_view.dart';
import 'package:word_game/views/home/home_view.dart';
import 'package:word_game/views/settings_view.dart';
import 'package:word_game/views/solo_view.dart';
import 'package:word_game/views/top_players_view.dart';

class Routes {
  static const home = '/';
  static const auth = '/auth';
  static const solo = '/solo';
  static const groups = '/groups';
  static const settings = '/settings';
  static const dict = '/dict';
  static const topPlayers = '/top_players';
  static const about = '/about';
}

GoRouter buildRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (_, __) => HomeView(),
      ),
      GoRoute(
        path: Routes.auth,
        builder: (_, __) => AuthView(),
      ),
      GoRoute(
        path: Routes.solo,
        builder: (_, __) => SoloView(),
      ),
      GoRoute(
        path: Routes.groups,
        builder: (_, __) => GroupsView(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (_, __) => SettingsView(),
      ),
      GoRoute(
        path: Routes.dict,
        builder: (_, __) => DictSearchView(),
      ),
      GoRoute(
        path: Routes.topPlayers,
        builder: (_, __) => TopPlayersView(),
      ),
      GoRoute(
        path: Routes.about,
        builder: (_, __) => AboutView(),
      ),
    ],
  );
}
