import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:word_game/app/router.dart';
import 'package:word_game/services/service_locator.dart';
import 'package:word_game/ui/entity_future_builder.dart';

typedef UserWidgetBuilder = Widget Function(BuildContext, User);

class UsernameLink extends StatelessWidget {
  final String id;
  final Key? innerKey;
  late final UserWidgetBuilder content;
  UsernameLink({
    required this.id,
    UserWidgetBuilder? content,
    this.innerKey,
    Key? key,
  }) : super(key: key) {
    this.content = content ?? (c, u) => Text(u.username, style: Theme.of(c).textTheme.headline6);
  }

  @override
  Widget build(BuildContext context) {
    return EntityFutureBuilder<User>(
      key: innerKey,
      id: id,
      store: userStore(),
      loadingWidget: SpinKitCircle(color: Colors.black87, size: 16),
      errorWidget: (_) => Icon(Icons.error),
      resultWidget: (u) => InkWell(
        onTap: () => context.push(Routes.user(id)),
        child: content(context, u),
      ),
    );
  }
}
