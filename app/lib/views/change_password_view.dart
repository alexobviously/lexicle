import 'package:common/common.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:word_game/services/api_client.dart';
import 'package:word_game/services/service_locator.dart';
import 'package:word_game/services/sound_service.dart';
import 'package:word_game/ui/neumorphic_text_field.dart';
import 'package:word_game/ui/standard_scaffold.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  @override
  Widget build(BuildContext context) {
    return StandardScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
          child: ChangePasswordForm(),
        ),
      ),
    );
  }
}

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  bool _showOldPassword = false;
  bool _showNewPassword = false;
  final _formKey = GlobalKey<FormState>();

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  String get _oldPassword => _oldPasswordController.text;
  String get _newPassword => _newPasswordController.text;

  void _toggleShowOldPassword() => setState(() => _showOldPassword = !_showOldPassword);
  void _toggleShowNewPassword() => setState(() => _showNewPassword = !_showNewPassword);

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final result = await ApiClient.changePassword(_oldPassword, _newPassword);
      sound().play(result.ok ? Sound.good : Sound.bad);
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.ok ? 'Changed password successfully!' : 'Error changing password: ${result.error}'),
        ),
      );
      if (result.ok) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            NeumorphicTextField(
              controller: _oldPasswordController,
              enableSuggestions: false,
              obscureText: !_showOldPassword,
              maxLength: passwordMaxLength,
              inputDecoration: InputDecoration(
                hintText: 'Enter your current password',
                label: Text('Current Password'),
                suffixIcon: IconButton(
                  onPressed: _toggleShowOldPassword,
                  icon: Icon(_showOldPassword ? MdiIcons.eyeOff : MdiIcons.eye),
                ),
              ),
            ),
            NeumorphicTextField(
              controller: _newPasswordController,
              enableSuggestions: false,
              obscureText: !_showNewPassword,
              maxLength: passwordMaxLength,
              inputDecoration: InputDecoration(
                hintText: 'Enter a new password',
                label: Text('New Password'),
                suffixIcon: IconButton(
                  onPressed: _toggleShowNewPassword,
                  icon: Icon(_showNewPassword ? MdiIcons.eyeOff : MdiIcons.eye),
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
                child: Text('Change Password', style: Theme.of(context).textTheme.headline6),
              ),
              onPressed: _submit,
            ),
          ],
        ));
  }
}
