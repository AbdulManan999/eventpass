import 'dart:convert';

class CheckDataException {
  /// Extracts `message` from a raw JSON error body.
  static String parseResponse(String response) {
    try {
      final decoded = jsonDecode(response);
      if (decoded is Map && decoded['message'] != null) return decoded['message'].toString();
    } catch (_) {}
    return response;
  }
}
