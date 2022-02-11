/// A generic structure for results to be returned in.
class Result<T> {
  final T? object;
  final String? error;
  final List<String> warnings;

  bool get ok => error == null;
  bool get hasObject => object != null;

  Result({this.object, this.error, this.warnings = const []}) {
    assert(!(error == null && object == null));
  }

  factory Result.error(String error, [List<String> warnings = const []]) => Result(error: error, warnings: warnings);
  factory Result.ok(T object, [List<String> warnings = const []]) => Result(object: object, warnings: warnings);

  @override
  String toString() {
    String str = ok ? 'ok, $object' : 'error, $error';
    if (warnings.isNotEmpty) str = '$str, $warnings';
    return 'Result($str)';
  }
}

class ApiResult<T> extends Result<T> {
  final String? token;
  final int? expiry;

  ApiResult({
    T? object,
    String? error,
    List<String> warnings = const [],
    this.token,
    this.expiry,
  }) : super(object: object, error: error, warnings: warnings);

  factory ApiResult.error(String error, [List<String> warnings = const []]) =>
      ApiResult(error: error, warnings: warnings);
  factory ApiResult.ok(T object, {String? token, int? expiry, List<String> warnings = const []}) =>
      ApiResult(object: object, token: token, expiry: expiry, warnings: warnings);

  @override
  String toString() {
    String str = ok ? 'ok, $object' : 'error, $error';
    if (warnings.isNotEmpty) str = '$str, $warnings';
    if (token != null) str = '$str, $token';
    return 'ApiResult($str)';
  }
}
