import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class MyAppBar extends NeumorphicAppBar {
  MyAppBar(BuildContext context, {bool showBackButton = true, Key? key})
      : super(
          key: key,
          leading: showBackButton && Navigator.of(context).canPop()
              ? NeumorphicBackButton(
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
        );
}
