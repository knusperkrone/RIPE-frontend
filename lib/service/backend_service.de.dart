import 'dart:convert';

import 'package:iftem/service/mixins/http_client_mixin.dart';
import 'package:optional/optional.dart';

import 'models/dto.dart';

class BackendService with DartHttpClientMixin {
  static const _BASE_URL = 'http://retroapp.if-lab.de:8000';

  Future<Optional<SensorDto>> getSensorData(int id, String key) async {
    try {
      final resp = await doGet(_BASE_URL, '/api/sensor/$id/$key', {});
      final json = jsonDecode(resp) as Map<String, dynamic>;
      return Optional.of(SensorDto.fromJson(json));
    } catch (e) {
      print('[ERROR] getSensorData $e');
      return const Optional.empty();
    }
  }

  Future<void> forceAgent(
      {int id, String key, String domain, bool active, int secs}) async {
    try {
      await doPost(_BASE_URL,
          '/api/agent/$id/$key/$domain?active=$active&secs=$secs', {}, '');
    } catch (e) {
      print('[ERROR] forceAgent $e');
    }
  }
}
