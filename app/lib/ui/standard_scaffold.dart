import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:word_game/ui/app_bar.dart';

class StandardScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final bool showAppBar;
  final bool showBackButton;
  const StandardScaffold({
    Key? key,
    required this.body,
    this.showAppBar = true,
    this.showBackButton = true,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? MyAppBar(title: title, showBackButton: showBackButton) : null,
      backgroundColor: NeumorphicTheme.baseColor(context),
      body: body,
    );
  }
}
