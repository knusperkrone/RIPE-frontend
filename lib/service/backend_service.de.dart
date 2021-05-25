import 'dart:collection';
import 'dart:convert';

import 'package:iftem/env.dart';
import 'package:iftem/service/mixins/http_client_mixin.dart';
import 'package:tuple/tuple.dart';

import 'models/dto.dart';

class BackendService with DartHttpClientMixin {
  Future<SensorDto?> getSensorData(int id, String key) async {
    try {
      final resp = await doGet(BACKEND_URL, '/api/sensor/$id/$key', {});

      final json = jsonDecode(resp) as Map<String, dynamic>;
      return SensorDto.fromJson(json);
    } catch (e) {
      print('[ERROR] BackendService.getSensorData - $e');
      return null;
    }
  }

  Future<bool> sendAgentCmd({
    required int id,
    required String key,
    required String domain,
    required int payload,
  }) async {
    try {
      await doPost(
        BACKEND_URL,
        '/api/agent/$id/$key/$domain',
        {'Content-Type': 'application/json'},
        jsonEncode({'payload': payload}),
      );

      return true;
    } catch (e) {
      print('[ERROR] BackendService.forceAgent - $e');
      return false;
    }
  }

  Future<Map<String, Tuple2<String, Map<String, dynamic>>>?> getAgentConfig({
    required int id,
    required String key,
    required String domain,
  }) async {
    try {
      final resp =
          await doGet(BACKEND_URL, '/api/agent/$id/$key/$domain/config', {});

      final json = jsonDecode(resp) as Map<String, dynamic>;
      final Map<String, List<dynamic>> casted = json.cast();
      final Map<String, Tuple2<String, Map<String, dynamic>>> transformed =
          casted.map((key, val) => MapEntry(
              key, Tuple2<String, Map<String, dynamic>>.fromList(val)));
      final Map<String, Tuple2<String, Map<String, dynamic>>> sorted =
          SplayTreeMap.from(transformed, (a, b) => a.compareTo(b));

      return sorted;
    } catch (e) {
      print('[ERROR] BackendService.getAgentConfig - $e');
      return null;
    }
  }

  Future<bool> setAgentConfig({
    required int id,
    required String key,
    required String domain,
    required Map<String, dynamic> settings,
  }) async {
    try {
      await doPost(
        BACKEND_URL,
        '/api/agent/$id/$key/$domain/config',
        {'Content-Type': 'application/json'},
        jsonEncode(settings),
      );
    } catch (e) {
      print('[ERROR] BackendService.setAgentConfig - $e');
      return false;
    }
    return true;
  }
}
