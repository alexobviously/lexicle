import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MyAppBar extends NeumorphicAppBar {
  MyAppBar(BuildContext context, {String? title, bool showBackButton = true, Key? key})
      : super(
          key: key,
          title: title != null
              ? Text(
                  title,
                  style: Theme.of(context).textTheme.headline4,
                )
              : null,
          leading: showBackButton && Navigator.of(context).canPop()
              ? NeumorphicBackButton(
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
          actions: [
            NeumorphicButton(
              onPressed: () => Navigator.of(context).pushNamed('/settings'),
              child: const Icon(MdiIcons.cog),
            ),
          ],
        );
}
