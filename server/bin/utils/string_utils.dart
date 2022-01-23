import 'dart:math';

import 'package:mongo_dart/mongo_dart.dart';

String randomCode() {
  final r = Random();
  final i = r.nextInt(999999);
  return '$i'.padLeft(6, '0');
}

String newId() => ObjectId().toHexString();
