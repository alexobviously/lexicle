import 'package:shelf/shelf.dart';

import '../services/service_locator.dart';
import '../utils/http_utils.dart';

class DictionaryHandler {
  static Future<Response> validateWord(Request request, String word) async {
    bool _valid = dictionary().isValidWord(word);
    return HttpUtils.buildResponse(
      data: {
        'word': word,
        'valid': _valid,
      },
    );
  }
}
