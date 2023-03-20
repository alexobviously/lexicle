import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:word_game/app/router.dart';

class LoginBox extends StatelessWidget {
  const LoginBox({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => context.push(Routes.auth),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        child: Neumorphic(
          style: const NeumorphicStyle(
            depth: -4.0,
            // boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.0)),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Log in to play online', style: textTheme.titleLarge),
              Container(height: 16),
              NeumorphicButton(
                onPressed: () => context.push(Routes.auth),
                style: NeumorphicStyle(
                  depth: 2,
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
                ),
                child: Text('Login', style: textTheme.titleLarge),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
