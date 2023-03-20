import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:word_game/app/router.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final List<Widget> actions;
  const MyAppBar({
    this.title,
    this.showBackButton = true,
    this.actions = const [],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool canGoBack = Navigator.of(context).canPop(); //Navigator.of(context).canPop();
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showBackButton)
                GestureDetector(
                  onTap: () => canGoBack ? context.pop() : context.go(Routes.home),
                  child: Icon(
                    canGoBack ? MdiIcons.chevronLeft : MdiIcons.home,
                    size: 30,
                  ),
                ),
              Spacer(),
              if (title != null)
                Text(
                  title!,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ...actions,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
