class ApiResponse {
  final String status;
  final Map<String, dynamic> data;
  final String? error;
  final List<String> warnings;
  final String? token;
  final int? expiry;

  bool get ok => status == 'ok';

  ApiResponse(
    this.status, {
    this.data = const {},
    this.error,
    this.warnings = const [],
    this.token,
    this.expiry,
  });

  factory ApiResponse.error(String error, [List<String> warnings = const []]) =>
      ApiResponse('error', error: error, warnings: warnings);

  factory ApiResponse.unknownError() => ApiResponse.error('unknown');

  factory ApiResponse.ok(Map<String, dynamic> data, {String? token, int? expiry, List<String> warnings = const []}) =>
      ApiResponse('ok', data: data, token: token, expiry: expiry, warnings: warnings);
}
