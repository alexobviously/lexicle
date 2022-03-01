import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:word_game/model/game_creation_data.dart';
import 'package:word_game/ui/game_creator.dart';

Future<GameCreationData?> showCreatorDialog(BuildContext context) async {
  return await showDialog<GameCreationData?>(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(side: BorderSide(), borderRadius: BorderRadius.circular(20.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GameCreator(
              depth: 0,
              showTitle: true,
              onCreate: (data) => Navigator.of(context).pop(data),
              onCancel: () => Navigator.of(context).pop(null),
            ),
          ],
        ),
      );
    },
  );
}
