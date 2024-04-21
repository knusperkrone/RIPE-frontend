import 'package:executor/executor.dart';
import 'package:ripe/db/database_service.dart';
import 'package:ripe/db/shared.dart';
import 'package:ripe/service/backend_service.dart';
import 'package:ripe/service/models/sensor.dart';
import 'package:ripe/util/log.dart';
import 'package:tuple/tuple.dart';

const _CACHE_LIFETIME = Duration(minutes: 10);
Tuple2<DateTime, List<SensorDataDao>>? _cache;

class SensorDataService {
  final _db = new DatabaseService();
  final _api = new BackendService();

  final RegisteredSensor sensor;

  SensorDataService(this.sensor);

  Future<List<SensorDataDao>> getHistoryData(
    DateTime from,
    DateTime until,
  ) async {
    from = normalizeDate(from);
    until = normalizeDate(until);

    final today = normalizeDate(DateTime.now());
    final isUntilToday = until.isAtSameMomentAs(today);
    if (isUntilToday) {
      until.subtract(const Duration(days: 1));
    }

    final daysToFetch = await _getNotFetchedDays(from, until);

    Log.info('Fetching ${daysToFetch.length} missing days');
    final _executor = new Executor(concurrency: 6);
    for (final toFetchDay in daysToFetch) {
      final dayFrom = toFetchDay;
      final dayUntil = toFetchDay.add(const Duration(days: 1));

      _executor.scheduleTask(() async {
        final dayData =
            await _api.getSensorData(sensor.id, sensor.key, dayFrom, dayUntil);
        await _db.insertDataWithHistory(sensor.id, dayData!, toFetchDay);
        await Future<void>.delayed(const Duration(seconds: 1), () {});
      });
    }
    await _executor.join(withWaiting: true);
    await _executor.close();

    final history = await _db.getData(sensor.id, from, until);
    if (isUntilToday) {
      history.addAll(await _getTodayData());
    }
    return history;
  }

  Future<DateTime> getFirstData() async {
    final firstData = await _db.getFirst(sensor.id);
    if (firstData == null) {
      Log.info('Fetching initial data');
      final apiData = await _api.getFirstData(sensor.id, sensor.key);
      await _db.insertFirstDay(sensor.id, apiData!.timestamp);
      return apiData.timestamp;
    } else {
      return firstData.initial;
    }
  }

  Future<List<SensorDataDao>> _getTodayData() async {
    if (_isCacheHealthy()) {
      Log.debug('Using cached history data');
      return _cache!.item2;
    }

    Log.debug('Caching history data from today');
    final now = DateTime.now();
    final from = normalizeDate(now);
    final data = (await _api.getSensorData(sensor.id, sensor.key, from, now))!
        .map((e) => _db.transformSensorData(sensor.id, e))
        .toList();

    _cache = new Tuple2(now, data);
    return data;
  }

  DateTime normalizeDate(DateTime date) => date.copyWith(
      hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  bool _isCacheHealthy() =>
      _cache?.item1.add(_CACHE_LIFETIME).isAfter(DateTime.now()) ?? false;

  Future<List<DateTime>> _getNotFetchedDays(
      DateTime before, DateTime after) async {
    final alreadyFetchedDays =
        (await _db.getHistory(sensor.id, before, after)).map((e) => e.day);

    // Iterate over time series and find gaps
    final gaps = <DateTime>[];
    for (DateTime curr = normalizeDate(before);
        curr.isBefore(after);
        curr = curr.add(const Duration(days: 1))) {
      if (!alreadyFetchedDays.contains(curr)) {
        gaps.add(curr);
      }
    }

    return gaps;
  }
}
