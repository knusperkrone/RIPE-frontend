import 'dart:convert';
import 'dart:io';

import 'package:iftem/service/mixins/http_client_mixin.dart';

class SensorServerService with DartHttpClientMixin {
  SensorServerService() : super() {
    setTimeout(const Duration(seconds: 2));
  }

  Future<bool> sendWifiConfig(String ssid, String pwd) async {
    HttpClientResponse resp;
    try {
      resp = await doRawPost(
          'http://192.168.4.1',
          '/config/wifi',
          {'Content-Type': 'application/json'},
          jsonEncode({'ssid': ssid, 'pwd': pwd}));
    } catch (e) {
      return false;
    }
    return resp.statusCode == 200;
  }
}
