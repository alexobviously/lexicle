import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/app/routes.dart';
import 'package:word_game/cubits/auth_controller.dart';
import 'package:word_game/ui/standard_scaffold.dart';
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
                Text(
                  'Lexicle',
                  style: textTheme.headline3,
                  textAlign: TextAlign.center,
                ),
                Container(height: 30),
                BlocBuilder<AuthController, AuthState>(
                  builder: (context, state) {
                    if (state.loggedIn) {
                      return UserDetails(user: state.user!);
                    } else {
                      return Container();
                    }
                  },
                ),
                Container(height: 20),
                NeumorphicButton(
                  onPressed: () => Navigator.of(context).pushNamed(Routes.solo),
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
                  ),
                  child: Text('Play Offline', style: textTheme.headline6),
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
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Version ${snapshot.data!.version}'),
              ),
            ],
          );
        } else {
          return Text('Version...');
        }
      },
    );
  }
}
