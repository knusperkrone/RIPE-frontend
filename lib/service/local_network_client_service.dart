import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:ripe/service/backend_service.dart';

import '../constants.dart';

class LocalNetworkClientService extends BackendService {


  final _client = new http.Client();

  Future<bool> checkAvailable() async {
    try {
      await _client.post(
        Uri.parse('$LOCAL_BASE_URL/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{}),
      );
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  Future<bool> sendWifiConfig(String ssid, String pwd) async {
    http.Response resp;
    try {
      resp = await _client.post(Uri.parse('$LOCAL_BASE_URL/config/wifi'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
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
}
