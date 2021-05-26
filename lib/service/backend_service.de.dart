import 'dart:collection';
import 'dart:convert';

import 'package:ripe/env.dart';
import 'package:ripe/service/base_pref_service.dart';
import 'package:ripe/service/mixins/http_client_mixin.dart';
import 'package:ripe/util/log.dart';
import 'package:tuple/tuple.dart';

import 'models/dto.dart';

class BackendService extends BasePrefService with DartHttpClientMixin {
  Future<SensorDto?> getSensorData(int id, String key) async {
    try {
      final resp = await doGet(baseUrl, '/api/sensor/$id/$key', {});
      final json = jsonDecode(resp) as Map<String, dynamic>;

      Log.debug('Fetched sensor data for $id');
      return SensorDto.fromJson(json);
    } catch (e) {
      Log.error('GetSensorData - $e');
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
        baseUrl,
        '/api/agent/$id/$key/$domain',
        {'Content-Type': 'application/json'},
        jsonEncode({'payload': payload}),
      );

      Log.debug('Send command to sensor $id, $payload');
      return true;
    } catch (e) {
      Log.error('forceAgent - $e');
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
          await doGet(baseUrl, '/api/agent/$id/$key/$domain/config', {});

      final json = jsonDecode(resp) as Map<String, dynamic>;
      final Map<String, List<dynamic>> casted = json.cast();
      final Map<String, Tuple2<String, Map<String, dynamic>>> transformed =
          casted.map((key, val) => MapEntry(
              key, Tuple2<String, Map<String, dynamic>>.fromList(val)));
      final Map<String, Tuple2<String, Map<String, dynamic>>> sorted =
          SplayTreeMap.from(transformed, (a, b) => a.compareTo(b));

      Log.debug('Fetched agent config $id $domain');
      return sorted;
    } catch (e) {
      Log.error('getAgentConfig - $e');
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
        baseUrl,
        '/api/agent/$id/$key/$domain/config',
        {'Content-Type': 'application/json'},
        jsonEncode(settings),
      );

      Log.debug('Set agent config $id $domain');
      return true;
    } catch (e) {
      Log.error('setAgentConfig - $e');
      return false;
    }
  }

  /*
   * setter/getter
   */

  set baseUrl(String url) {
    prefs.setString('BASE_URL_V1', url);
  }

  String get baseUrl {
    return prefs.getString('BASE_URL_V1') ?? BACKEND_URL;
  }
}
