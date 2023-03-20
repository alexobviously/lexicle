import 'package:common/common.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:word_game/services/service_locator.dart';
import 'package:word_game/ui/neumorphic_text_field.dart';

class RegisterForm extends StatefulWidget {
  RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool _showPassword = false;
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();
  String get _username => _usernameController.text;
  String get _password => _passwordController.text;
  String get _password2 => _password2Controller.text;

  void _toggleShowPassword() => setState(() => _showPassword = !_showPassword);

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final _result = await auth().register(_username, _password);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(_result.ok ? 'Registered as ${_result.object!.username}!' : 'Registration failed: ${_result.error}'),
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
              maxLength: usernameMaxLength,
              controller: _usernameController,
              hintText: 'Enter a username',
              label: Text('Username'),
              validator: (val) {
                if (val == null) return '';
                if (val.length > usernameMaxLength || val.length < usernameMinLength) {
                  return 'Must be between $usernameMinLength and $usernameMaxLength characters';
                }
                if (!isValidUsername(val)) return 'Can only use a-z, 0-9, - and _';
                return null;
              },
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
              validator: (val) {
                if (val == null) return '';
                if (val.length < passwordMinLength || val.length > passwordMaxLength) {
                  return 'Must be between $passwordMinLength and $passwordMaxLength characters';
                }
                return null;
              },
            ),
            Container(height: 16),
            NeumorphicTextField(
              controller: _password2Controller,
              enableSuggestions: false,
              obscureText: !_showPassword,
              maxLength: passwordMaxLength,
              inputDecoration: InputDecoration(
                hintText: 'Enter the password again',
                label: Text('Confirm Password'),
                suffixIcon: IconButton(
                  onPressed: _toggleShowPassword,
                  icon: Icon(_showPassword ? MdiIcons.eyeOff : MdiIcons.eye),
                ),
              ),
              validator: (val) {
                if (val == null) return '';
                if (val != _password) return 'Passwords must match';
                return null;
              },
            ),
            Container(height: 32),
            NeumorphicButton(
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text('Register', style: Theme.of(context).textTheme.headline6),
              ),
              onPressed: _register,
            ),
          ],
        ));
  }
}
