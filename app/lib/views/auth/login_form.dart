import 'package:common/common.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:word_game/services/service_locator.dart';
import 'package:word_game/ui/neumorphic_text_field.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _showPassword = false;
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String get _username => _usernameController.text;
  String get _password => _passwordController.text;

  void _toggleShowPassword() => setState(() => _showPassword = !_showPassword);

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final _result = await auth().login(_username, _password);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_result.ok ? 'Logged in as ${_result.object!.username}' : 'Login failed: ${_result.error}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            NeumorphicTextField(
              controller: _usernameController,
              hintText: 'Enter a username',
              label: Text('Username'),
              maxLength: usernameMaxLength,
            ),
            Container(height: 16),
            NeumorphicTextField(
              controller: _passwordController,
              enableSuggestions: false,
              obscureText: !_showPassword,
              maxLength: passwordMaxLength,
              inputDecoration: InputDecoration(
                hintText: 'Enter a password',
                label: Text('Password'),
                suffixIcon: IconButton(
                  onPressed: _toggleShowPassword,
                  icon: Icon(_showPassword ? MdiIcons.eyeOff : MdiIcons.eye),
                ),
              ),
            ),
            Container(height: 32),
            NeumorphicButton(
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text('Login', style: Theme.of(context).textTheme.headline6),
              ),
              onPressed: _login,
            ),
          ],
        ));
  }
}
