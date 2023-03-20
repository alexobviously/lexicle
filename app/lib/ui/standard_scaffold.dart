import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:word_game/ui/app_bar.dart';

class StandardScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final bool showAppBar;
  final bool showBackButton;
  final List<Widget> appBarActions;
  const StandardScaffold({
    super.key,
    required this.body,
    this.showAppBar = true,
    this.showBackButton = true,
    this.title,
    this.appBarActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? MyAppBar(
              title: title,
              showBackButton: showBackButton,
              actions: appBarActions,
            )
          : null,
      backgroundColor: NeumorphicTheme.baseColor(context),
      body: body,
    );
  }
}
