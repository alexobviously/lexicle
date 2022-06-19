import 'dart:convert';
import 'dart:math';

import 'package:common/common.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:shelf/shelf.dart';
import 'package:validators/validators.dart';

import '../services/service_locator.dart';
import 'http_utils.dart';

const saltRounds = 10;
const jwtIssuer = 'Lexicle';
const jwtDuration = Duration(days: 7);
const jwtReissueDuration = Duration(days: 2);

String randomCryptoString([int length = 100]) {
  Random _random = Random.secure();
  final values = List<int>.generate(length, (i) => _random.nextInt(256));
  return base64Url.encode(values);
}

String encrypt(String plain) => DBCrypt().hashpw(plain, DBCrypt().gensaltWithRounds(saltRounds));
bool checkpw(String plain, String hashed) => DBCrypt().checkpw(plain, hashed);

TokenData issueToken(String user) {
  DateTime issuedAt = DateTime.now();
  final claimSet = JwtClaim(
    subject: user,
    issuer: jwtIssuer,
    issuedAt: issuedAt,
    maxAge: jwtDuration,
  );
  String token = issueJwtHS256(claimSet, env().jwtSecret);
  return TokenData.issued(
    token: token,
    expiry: issuedAt.add(jwtDuration).millisecondsSinceEpoch,
    subject: user,
  );
}

TokenData verifyToken(String token, [bool forceRenew = false]) {
  try {
    JwtClaim claimSet = verifyJwtHS256Signature(token, env().jwtSecret);
    DateTime now = DateTime.now();
    DateTime expiry = claimSet.expiry!;
    Duration timeToExpiry = expiry.difference(now);
    // Automatically reissue token if it's close to expiry
    if (expiry.isBefore(now)) return TokenData.expired();
    if (timeToExpiry.compareTo(jwtReissueDuration) < 0) {
      return issueToken(claimSet.subject!).copyWith(status: TokenStatus.old);
    } else {
      if (forceRenew) {
        return issueToken(claimSet.subject!);
      } else {
        return TokenData.ok(subject: claimSet.subject);
      }
    }
  } on JwtException {
    // print('Invalid token');
  } catch (e) {
    print('Unhandled exception in verifyToken: $e');
  }
  return TokenData.invalid();
}

TokenData verifyHeaders(Map<String, String> headers, [bool forceRenewToken = false]) {
  String? authorization = headers['authorization'];
  if (authorization != null && authorization.startsWith('Bearer ')) {
    String token = authorization.substring('Bearer '.length);
    return verifyToken(token, forceRenewToken);
  } else {
    return TokenData.invalid();
  }
}

typedef AuthPredicate = bool Function(String);

Future<AuthResult> authenticateRequest(Request request, {bool needAdmin = false, AuthPredicate? predicate}) async {
  final tokenData = verifyHeaders(request.headers);
  if (!tokenData.valid) {
    return AuthResult.error(Errors.unauthorised, tokenData);
  }
  String id = tokenData.subject!;
  if (!isMongoId(id)) return AuthResult.error('invalid_token');
  if (predicate != null && !predicate(id)) {
    return AuthResult.error(Errors.unauthorised);
  }
  final _result = await userStore().get(id);
  if (!_result.ok) return AuthResult.error(_result.error!);
  if (needAdmin && !_result.object!.isAdmin) return AuthResult.error(Errors.unauthorised);
  return AuthResult.ok(tokenData, _result.object!);
}

AuthPredicate matchOneUser(String id) => ((String x) => x == id);
AuthPredicate userInList(List<String> list) => ((String x) => list.contains(x));

class TokenData {
  final TokenStatus status;
  final String? token;
  final int? expiry;
  final String? subject; // a user id

  bool get valid => [TokenStatus.issued, TokenStatus.ok, TokenStatus.old].contains(status);

  const TokenData({this.status = TokenStatus.ok, this.token, this.expiry, this.subject});
  factory TokenData.ok({String? token, int? expiry, String? subject}) =>
      TokenData(token: token, expiry: expiry, subject: subject);
  factory TokenData.issued({
    required String token,
    required int expiry,
    String? subject,
  }) =>
      TokenData(
        status: TokenStatus.issued,
        token: token,
        expiry: expiry,
        subject: subject,
      );
  factory TokenData.expired() => TokenData(status: TokenStatus.expired);
  factory TokenData.invalid() => TokenData(status: TokenStatus.invalid);

  Map<String, dynamic> toMap([bool onlyToken = true]) => {
        if (!onlyToken) 'status': status.name,
        if (token != null) 'token': token,
        if (expiry != null) 'expiry': expiry,
        if (subject != null && !onlyToken) 'subject': subject,
      };

  TokenData copyWith({
    TokenStatus? status,
    String? token,
    int? expiry,
    String? subject,
  }) =>
      TokenData(
        status: status ?? this.status,
        token: token ?? this.token,
        expiry: expiry ?? this.expiry,
        subject: subject ?? this.subject,
      );
}

enum TokenStatus {
  issued,
  ok,
  old,
  expired,
  invalid,
}

class AuthResult {
  final TokenData? tokenData;
  final User? user;
  String? error;
  bool get ok => error == null && (tokenData?.valid ?? false);
  bool get hasUser => user != null;
  Response get errorResponse => HttpUtils.buildErrorResponse(error ?? '', tokenData: tokenData);

  AuthResult({this.tokenData, this.user, this.error});
  factory AuthResult.ok(TokenData tokenData, User user) => AuthResult(
        tokenData: tokenData,
        user: user,
      );
  factory AuthResult.error(String error, [TokenData? tokenData]) => AuthResult(error: error, tokenData: tokenData);
}
