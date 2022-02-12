import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:word_game/app/router.dart';
import 'package:word_game/cubits/auth_controller.dart';
import 'package:word_game/ui/standard_scaffold.dart';
import 'package:word_game/views/auth/login_form.dart';
import 'package:word_game/views/auth/register_form.dart';

class AuthView extends StatefulWidget {
  const AuthView({Key? key}) : super(key: key);

  @override
  _AuthViewState createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void initState() {
    if (mounted) _controller.addListener(() => setState(() => _page = _controller.page?.round() ?? 0));
    super.initState();
  }

  void _changePage(int p) {
    _controller.animateToPage(
      p,
      duration: Duration(milliseconds: 250),
      curve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return BlocListener<AuthController, AuthState>(
      listener: (context, state) {
        if (state.loggedIn) {
          context.go(Routes.home);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Logged in!'),
          ));
        }
      },
      child: StandardScaffold(
        body: Center(
          child: SafeArea(
            child: Column(
              children: [
                Container(height: 8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: NeumorphicToggle(
                    selectedIndex: _page,
                    displayForegroundOnlyIfSelected: true,
                    children: [
                      _toggleElement(context, 'Login'),
                      _toggleElement(context, 'Register'),
                    ],
                    thumb: Neumorphic(
                      style: NeumorphicStyle(
                        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.all(Radius.circular(12))),
                      ),
                    ),
                    onChanged: _changePage,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: PageView(
                      controller: _controller,
                      children: [
                        LoginForm(),
                        RegisterForm(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ToggleElement _toggleElement(BuildContext context, String text) {
    return ToggleElement(
      foreground: Center(
          child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      )),
      background: Center(child: Text(text)),
    );
  }
}
