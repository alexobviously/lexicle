class ApiResponse {
  final String status;
  final Map<String, dynamic> data;
  final String? error;
  final List<String> warnings;

  bool get ok => status == 'ok';

  ApiResponse(
    this.status, {
    this.data = const {},
    this.error,
    this.warnings = const [],
  });

  factory ApiResponse.error(String error, [List<String> warnings = const []]) =>
      ApiResponse('error', error: error, warnings: warnings);

  factory ApiResponse.unknownError() => ApiResponse.error('unknown');

  factory ApiResponse.ok(Map<String, dynamic> data, [List<String> warnings = const []]) =>
      ApiResponse('ok', data: data, warnings: warnings);
}
