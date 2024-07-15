import 'package:drift/drift.dart';
import 'package:executor/executor.dart';
import 'package:ripe/service/models/dto.dart';

import 'shared.dart';

class DatabaseService {
  static DatabaseService? _instance;

  factory DatabaseService() => _instance ??= DatabaseService._();

  DatabaseService._() : _db = constructDb();

  static const int _BATCH_SIZE = 24;
  final SharedDatabase _db;

  Future<List<SensorDaoData>> getData(
      int sensorId, DateTime from, DateTime until) async {
    return (_db.select(_db.sensorDao)
          ..where((tbl) => tbl.sensorId.equals(sensorId))
          ..where((tbl) => tbl.timestamp.isBetweenValues(from, until))
          ..orderBy([
            (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.asc)
          ]))
        .get();
  }

  Future<void> insertFirstDay(int sensorId, DateTime timestamp) async {
    await _db.into(_db.initialSensorData).insert(
        InitialSensorDataCompanion.insert(
            sensorId: sensorId, initial: timestamp));
  }

  Future<InitialSensorDataData?> getFirst(int sensorId) async {
    return (_db.select(_db.initialSensorData)
          ..where((tbl) => tbl.sensorId.equals(sensorId)))
        .getSingleOrNull();
  }

  Future<List<FetchHistory>> getHistory(
      int sensorId, DateTime from, DateTime until) {
    return (_db.select(_db.fetchHistories)
          ..where((tbl) => tbl.sensorId.equals(sensorId))
          ..where((tbl) => tbl.day.isBiggerOrEqualValue(from))
          ..where((tbl) => tbl.day.isSmallerThanValue(until))
          ..orderBy(
            [(t) => OrderingTerm(expression: t.day, mode: OrderingMode.asc)],
          ))
        .get();
  }

  Future<SensorDaoData> insertSingle(
      int sensorId, SensorDataDto element) async {
    return _db.into(_db.sensorDao).insertReturning(SensorDaoCompanion.insert(
        sensorId: sensorId,
        timestamp: element.timestamp,
        battery: Value(element.battery),
        moisture: Value(element.moisture),
        temperature: Value(element.temperature),
        humidity: Value(element.humidity),
        carbon: Value(element.carbon),
        conductivity: Value(element.conductivity),
        light: Value(element.light)));
  }

  Future<void> insertDataWithHistory(
      int sensorId, List<SensorDataDto> elements, DateTime day) async {
    final from = day;
    final until = day.add(const Duration(days: 1));
    final executor = new Executor(concurrency: _BATCH_SIZE);

    for (final element in elements) {
      assert((element.timestamp.isAfter(from) ||
              element.timestamp.isAtSameMomentAs(from)) &&
          (element.timestamp.isBefore(until) ||
              element.timestamp.isAtSameMomentAs(until)));

      executor.scheduleTask(
        () async => await _db.into(_db.sensorDao).insert(
            SensorDaoCompanion.insert(
                sensorId: sensorId,
                timestamp: element.timestamp,
                battery: Value(element.battery),
                moisture: Value(element.moisture),
                humidity: Value(element.humidity),
                temperature: Value(element.temperature),
                carbon: Value(element.carbon),
                conductivity: Value(element.conductivity),
                light: Value(element.light))),
      );
    }

    try {
      await executor.join(withWaiting: true);
      await _db.into(_db.fetchHistories).insert(
            FetchHistoriesCompanion.insert(sensorId: sensorId, day: day),
          );
    } catch (_) {
      _db.delete(_db.sensorDao).where((tbl) =>
          tbl.timestamp.isBiggerOrEqualValue(elements.first.timestamp));
      _db.delete(_db.sensorDao).where((tbl) =>
          tbl.timestamp.isSmallerOrEqualValue(elements.last.timestamp));
      _db.delete(_db.fetchHistories)
        ..where((tbl) => tbl.sensorId.equals(sensorId))
        ..where((tbl) => tbl.day.equals(day));
    } finally {
      await executor.close();
    }
  }

  SensorDaoData transformSensorData(int sensorId, SensorDataDto element) {
    return SensorDaoData(
      id: -1,
      sensorId: sensorId,
      timestamp: element.timestamp,
      battery: element.battery,
      moisture: element.moisture,
      temperature: element.temperature,
      humidity: element.humidity,
      carbon: element.carbon,
      conductivity: element.conductivity,
      light: element.light,
    );
  }

  SharedDatabase get db => _db;
}
