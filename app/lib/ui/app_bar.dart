import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:word_game/app/routes.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  const MyAppBar({this.title, this.showBackButton = true, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool canGoBack = showBackButton && Navigator.of(context).canPop();
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
              if (canGoBack)
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    MdiIcons.chevronLeft,
                    size: 30,
                  ),
                ),
              Spacer(),
              if (title != null)
                Text(
                  title!,
                  style: Theme.of(context).textTheme.headline6,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
