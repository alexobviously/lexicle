import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:word_game/ui/app_bar.dart';

class StandardScaffold extends StatelessWidget {
  final Widget body;
  final bool showBackButton;
  const StandardScaffold({
    Key? key,
    required this.body,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(context, showBackButton: showBackButton),
      backgroundColor: NeumorphicTheme.baseColor(context),
      body: body,
    );
  }
}
