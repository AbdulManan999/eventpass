import 'dart:io';

class NetworkConnection {
  /// Lightweight reachability check (DNS lookup). No extra package needed.
  static Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
