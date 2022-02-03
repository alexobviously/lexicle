import 'dart:convert';
import 'dart:math';

import 'package:dbcrypt/dbcrypt.dart';

const SALT_ROUNDS = 10;

String randomCryptoString([int length = 100]) {
  Random _random = Random.secure();
  final values = List<int>.generate(length, (i) => _random.nextInt(256));
  return base64Url.encode(values);
}

String encrypt(String plain) => DBCrypt().hashpw(plain, DBCrypt().gensaltWithRounds(SALT_ROUNDS));
bool checkpw(String plain, String hashed) => DBCrypt().checkpw(plain, hashed);
