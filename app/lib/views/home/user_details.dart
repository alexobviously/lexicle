import 'package:common/common.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:word_game/app/router.dart';
import 'package:word_game/services/service_locator.dart';
import 'package:word_game/services/sound_service.dart';

class UserDetails extends StatelessWidget {
  final User user;
  final UserStats stats;
  const UserDetails({super.key, required this.user, required this.stats});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => context.push(Routes.user(user.id)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        child: Neumorphic(
          style: const NeumorphicStyle(
            depth: -4.0,
            // boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.0)),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(user.username, style: textTheme.headline5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rating: ${user.rating.rating.toStringAsFixed(0)}'),
                        Text('Games played: ${stats.groupsTotal}'),
                        Text('Wins: ${stats.winsTotal}'),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Column(
                      children: [
                        NeumorphicButton(
                          style: NeumorphicStyle(depth: 3),
                          child: Text('Log Out'),
                          onPressed: () {
                            auth().logout();
                            sound().play(Sound.clickDown);
                            HapticFeedback.mediumImpact();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
