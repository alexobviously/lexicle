import 'package:flutter/material.dart';
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('Log in to play online', style: textTheme.titleLarge),
              Container(height: 16),
              ElevatedButton(
                onPressed: () => context.push(Routes.auth),
                child: Text('Login', style: textTheme.titleLarge),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
