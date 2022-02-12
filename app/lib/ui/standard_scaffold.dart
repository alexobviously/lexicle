import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:word_game/cubits/app_link_handler.dart';
import 'package:word_game/ui/app_bar.dart';
import 'package:word_game/views/app_link_view.dart';
import 'package:word_game/views/stats_view.dart';

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
    return BlocListener<AppLinkHandler, AppLinkData>(
      listener: (context, link) {
        print('### BLOC LISTENER $link');
        if (link.hasLink) {
          print(link);
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            BlocProvider.of<AppLinkHandler>(context).clear();
            // Navigator.of(context).push(MaterialPageRoute(builder: (context) => AppLinkView(link)));
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => StatsView(id: link.data!)));
            // just for testing, not actual behaviour
          });
        }
      },
      child: Scaffold(
        appBar: showAppBar ? MyAppBar(title: title, showBackButton: showBackButton) : null,
        backgroundColor: NeumorphicTheme.baseColor(context),
        body: body,
      ),
    );
  }
}
