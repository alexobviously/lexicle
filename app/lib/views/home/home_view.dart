import 'package:common/common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/app/routes.dart';
import 'package:word_game/cubits/auth_controller.dart';
import 'package:word_game/cubits/server_meta_cubit.dart';
import 'package:word_game/model/server_meta.dart';
import 'package:word_game/services/service_locator.dart';
import 'package:word_game/ui/standard_scaffold.dart';
import 'package:word_game/ui/word_row.dart';
import 'package:word_game/views/home/animated_logo.dart';
import 'package:word_game/views/home/user_details.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return StandardScaffold(
      showBackButton: false,
      body: Center(
        child: SafeArea(
          child: BlocBuilder<AuthController, AuthState>(builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: const AnimatedLogo(),
                ),
                Container(height: 30),
                BlocBuilder<AuthController, AuthState>(
                  builder: (context, state) {
                    if (state.loggedIn) {
                      return UserDetails(
                        user: state.user!,
                        stats: state.stats ?? UserStats(id: state.userId!),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
                Container(height: 20),
                NeumorphicButton(
                  onPressed: () => Navigator.of(context).pushNamed(state.loggedIn ? Routes.groups : Routes.auth),
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
                  ),
                  child: Text(state.loggedIn ? 'Play Online' : 'Login', style: textTheme.headline6),
                ),
                Container(height: 20),
                NeumorphicButton(
                  onPressed: () => Navigator.of(context).pushNamed(Routes.solo),
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
                  ),
                  child: Text('Practice', style: textTheme.headline6),
                ),
                Container(height: 20),
                NeumorphicButton(
                  onPressed: () => Navigator.of(context).pushNamed(Routes.dict),
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
                  ),
                  child: Text('Dictionary', style: textTheme.headline6),
                ),
                Spacer(),
                _version(),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _version() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return BlocBuilder<ServerMetaCubit, ServerMeta>(
            builder: (context, meta) {
              Version localVersion = Version.parse(snapshot.data!.version);
              bool updateAvailable = meta.loaded && localVersion < Version.parse(meta.appCurrentVersion);
              bool updateNeeded = meta.loaded && localVersion < Version.parse(meta.appMinVersion);
              return Container(
                color: updateNeeded
                    ? Colours.invalid.lighten(0.1)
                    : updateAvailable
                        ? Colours.victory
                        : null,
                child: Row(
                  children: [
                    if (updateAvailable || updateNeeded)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(updateNeeded ? 'Update required' : 'Update available'),
                      ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Version $localVersion'),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return Text('Version...');
        }
      },
    );
  }
}
