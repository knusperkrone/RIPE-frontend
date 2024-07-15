import 'package:drift/drift.dart';
import 'database_service.dart';

export 'base.dart'
    if (dart.library.ffi) 'native.dart'
    if (dart.library.html) 'web.dart';

part 'shared.g.dart';

class SensorDao extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get sensorId => integer()();

  DateTimeColumn get timestamp => dateTime()();

  RealColumn get battery => real().nullable()();

  RealColumn get moisture => real().nullable()();

  RealColumn get temperature => real().nullable()();

  RealColumn get humidity => real().nullable()();

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
  SensorDao,
  InitialSensorData,
  FetchHistories,
])
class SharedDatabase extends _$SharedDatabase {
  SharedDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (m) async {},
        onUpgrade: (m, from, to) async {
          final _db = DatabaseService().db;

          if (from < 1) {
            customStatement("ALTER TABLE sensor_data RENAME TO sensor_dao;");
            await m.addColumn(_db.sensorDao, _db.sensorDao.humidity);
          }
        },
      );
}
