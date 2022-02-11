import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:word_game/app/colours.dart';

class AppLinkView extends StatefulWidget {
  final String link;
  const AppLinkView(this.link, {Key? key}) : super(key: key);

  @override
  State<AppLinkView> createState() => _AppLinkViewState();
}

class _AppLinkViewState extends State<AppLinkView> {
  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: SpinKitCircle(
        color: Colours.victory,
        size: 64,
      )),
      backgroundColor: NeumorphicTheme.baseColor(context),
    );
  }
}
