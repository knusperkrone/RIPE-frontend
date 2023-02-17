import 'package:drift/drift.dart';

export 'base.dart'
    if (dart.library.ffi) 'native.dart'
    if (dart.library.html) 'web.dart';

part 'shared.g.dart';

class SensorData extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get sensorId => integer()();

  DateTimeColumn get timestamp => dateTime()();

  RealColumn get battery => real().nullable()();

  RealColumn get moisture => real().nullable()();

  RealColumn get temperature => real().nullable()();

  IntColumn get carbon => integer().nullable()();

  IntColumn get conductivity => integer().nullable()();

  IntColumn get light => integer().nullable()();
}

class InitialSensorData extends Table {
  IntColumn get sensorId => integer()();

  DateTimeColumn get initial => dateTime()();

  @override
  Set<Column> get primaryKey => {sensorId, initial};
}

class FetchHistories extends Table {
  IntColumn get sensorId => integer()();

  DateTimeColumn get day => dateTime()();

  @override
  Set<Column> get primaryKey => {sensorId, day};
}

@DriftDatabase(tables: [
  SensorData,
  InitialSensorData,
  FetchHistories,
])
class SharedDatabase extends _$SharedDatabase {
  SharedDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}
