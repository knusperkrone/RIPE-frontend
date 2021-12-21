import 'dart:convert';
import 'dart:io';

import 'package:ripe/service/backend_service.dart';

class SensorServerService extends BackendService {
  static const String _BASE_URL = 'http://192.168.4.1';

  final HttpClient _client = new HttpClient()
    ..connectionTimeout = const Duration(milliseconds: 1000)
    ..badCertificateCallback = (_, __, ___) => true;

  Future<bool> checkAvailable() async {
    try {
      await unchunkedPost(
        _BASE_URL,
        '/',
        {'Content-Type': 'application/json'},
        jsonEncode(<String, dynamic>{}),
      );
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  Future<bool> sendWifiConfig(String ssid, String pwd) async {
    HttpClientResponse resp;
    try {
      resp = await unchunkedPost(
          _BASE_URL,
          '/config/wifi',
          {'Content-Type': 'application/json'},
          jsonEncode({
            'ssid': ssid,
            'pwd': pwd,
            'base_url': baseUrl,
          }));
    } catch (e) {
      print(e);
      return false;
    }
    return resp.statusCode == 200;
  }

  Future<HttpClientResponse> unchunkedPost(String base, String path,
      Map<String, String> headers, String body) async {
    assert(path.codeUnitAt(0) == '/'.codeUnitAt(0));
    final req = await _client.postUrl(Uri.parse('$base$path'));
    req.headers.chunkedTransferEncoding = false;
    req.headers.contentLength = body.length;
    headers.forEach((key, value) => req.headers.set(key, value));
    req.add(utf8.encode(body));

    return await req.close();
  }
}
