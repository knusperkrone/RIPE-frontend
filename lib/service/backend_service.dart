import 'dart:collection';
import 'dart:convert';

import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
import 'package:ripe/constants.dart';
import 'package:ripe/service/mixins/http_client_mixin.dart';
import 'package:ripe/service/models/sensor.dart';
import 'package:ripe/service/settings/base_pref_service.dart';
import 'package:ripe/util/log.dart';
import 'package:tuple/tuple.dart';

import 'models/dto.dart';

class BackendService extends BasePrefService with DartHttpClientMixin {
  Future<SensorDto> getSensorStatus(RegisteredSensor sensor) async {
    final currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    try {
      final resp = await doGet(baseUrl, '/api/sensor/${sensor.id}', {
        'X-TZ': currentTimeZone,
        'X-KEY': sensor.key,
      });
      final json =
          jsonDecode(utf8.decode(resp.codeUnits)) as Map<String, dynamic>;

      Log.debug('Fetched sensor status for ${sensor.id}');
      return SensorDto.fromJson(json);
    } catch (e) {
      Log.error('FetchSensorData - $e');
      rethrow;
    }
  }

  Future<void> sendAgentCmd({
    required int id,
    required String key,
    required String domain,
    required int payload,
  }) async {
    try {
      await doPost(
        baseUrl,
        '/api/agent/$id/${base64.encode(utf8.encode(domain))}',
        {
          'Content-Type': 'application/json',
          'X-KEY': key,
        },
        jsonEncode({'payload': payload}),
      );

      Log.debug('Send command to sensor $id, $payload');
    } catch (e) {
      Log.error('sendAgentCmd - $e');
      rethrow;
    }
  }

  Future<List<String>?> getSensorLogs(int id, String key) async {
    final currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    try {
      final resp = await doGet(baseUrl, '/api/sensor/$id/log', {
        'X-TZ': currentTimeZone,
        'X-KEY': key,
      });
      final json = jsonDecode(resp) as List<dynamic>;
      final logs = json.cast<String>();

      Log.debug('Fetched sensor logs for $id');
      return logs;
    } catch (e) {
      Log.error('GetSensorLogs - $e');
      return null;
    }
  }

  Future<List<SensorDataDto>?> getSensorData(
      int id, String key, DateTime from, DateTime until) async {
    final queryParams = <String, dynamic>{
      'from': from.toUtc().toIso8601String(),
      'until': until.toUtc().toIso8601String()
    };
    final encodedQuery = Uri(queryParameters: queryParams).query;

    try {
      final resp = await doGet(baseUrl, '/api/sensor/$id/data?$encodedQuery', {
        'X-KEY': key,
      });
      final jsonList = jsonDecode(resp) as List<dynamic>;
      final json = jsonList.cast<Map<String, dynamic>>();

      Log.debug('Fetched sensor data for $id');
      return json.map((str) => SensorDataDto.fromJson(str)).toList();
    } catch (e) {
      Log.error('GetSensorData - $e');
      return null;
    }
  }

  Future<SensorDataDto?> getFirstData(int id, String key) async {
    try {
      final resp = await doGet(baseUrl, '/api/sensor/$id/data/first', {
        'X-KEY': key,
      });
      final json = jsonDecode(resp) as Map<String, dynamic>;

      Log.debug('Fetched sensor data for $id');
      return SensorDataDto.fromJson(json);
    } catch (e) {
      Log.error('GetSensorLogs - $e');
      return null;
    }
  }

  Future<Map<String, Tuple2<String, Map<String, dynamic>>>?> getAgentConfig(
      RegisteredSensor sensor, String domain) async {
    final currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    try {
      final resp = await doGet(
          baseUrl,
          '/api/agent/${sensor.id}/${base64.encode(utf8.encode(domain))}/config',
          {
            'X-TZ': currentTimeZone,
            'X-KEY': sensor.key,
          });

      final json = jsonDecode(resp) as Map<String, dynamic>;
      final Map<String, List<dynamic>> casted = json.cast();
      final Map<String, Tuple2<String, Map<String, dynamic>>> transformed =
          casted.map((key, val) => MapEntry(
              key, Tuple2<String, Map<String, dynamic>>.fromList(val)));
      final Map<String, Tuple2<String, Map<String, dynamic>>> sorted =
          SplayTreeMap.from(transformed, (a, b) => a.compareTo(b));

      Log.debug('Fetched agent config ${sensor.id} $domain');
      return sorted;
    } catch (e) {
      Log.error('getAgentConfig - $e');
      return null;
    }
  }

  Future<void> setAgentConfig({
    required RegisteredSensor sensor,
    required String domain,
    required Map<String, dynamic> settings,
  }) async {
    final currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    try {
      await doPost(
        baseUrl,
        '/api/agent/${sensor.id}/${base64.encode(utf8.encode(domain))}/config',
        {
          'Content-Type': 'application/json',
          'X-TZ': currentTimeZone,
          'X-KEY': sensor.key,
        },
        jsonEncode(settings),
      );

      Log.debug('Set agent config ${sensor.id} $domain');
    } catch (e) {
      Log.error('setAgentConfig - $e');
      rethrow;
    }
  }

  Future<bool> checkBaseUrl(String tmpBaseUrl) async {
    try {
      await doGet(tmpBaseUrl, '/api/health', {});
      Log.debug('Valid baseUrl $tmpBaseUrl');
      return true;
    } catch (e) {
      Log.error('checkBaseUrl - $e');
      return false;
    }
  }

  /*
   * setter/getter
   */

  set baseUrl(String url) {
    prefs.setString(BASE_URL_KEY, url);
  }

  String get baseUrl {
    return prefs.getString(BASE_URL_KEY) ?? DEFAULT_BASE_URL;
  }
}
