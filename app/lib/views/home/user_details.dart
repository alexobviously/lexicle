import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(user.username, style: textTheme.headlineSmall),
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
                        ElevatedButton(
                          child: const Text('Log Out'),
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
