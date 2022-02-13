import 'package:flutter/material.dart';
import 'package:word_game/app/colours.dart';

Future<bool> showConfirmationDialog(
  BuildContext context, {
  String title = 'Are you sure?',
  String body = '',
  String? positiveText,
  String? negativeText,
}) async {
  final textTheme = Theme.of(context).textTheme;
  final buttonTextStyle = textTheme.headline6!.copyWith(color: Colours.correct.darken(0.3));
  return await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              title,
              style: textTheme.headline5,
            ),
            content: Text(body),
            actions: [
              OutlinedButton(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    negativeText ?? 'Cancel',
                    style: buttonTextStyle,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              OutlinedButton(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    positiveText ?? 'Ok',
                    style: buttonTextStyle,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              )
            ],
          );
        },
      ) ??
      false;
}
