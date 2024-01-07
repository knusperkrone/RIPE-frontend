// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared.dart';

// ignore_for_file: type=lint
class $SensorDataTable extends SensorData
    with TableInfo<$SensorDataTable, SensorDataDao> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SensorDataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sensorIdMeta =
      const VerificationMeta('sensorId');
  @override
  late final GeneratedColumn<int> sensorId = GeneratedColumn<int>(
      'sensor_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _batteryMeta =
      const VerificationMeta('battery');
  @override
  late final GeneratedColumn<double> battery = GeneratedColumn<double>(
      'battery', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _moistureMeta =
      const VerificationMeta('moisture');
  @override
  late final GeneratedColumn<double> moisture = GeneratedColumn<double>(
      'moisture', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _temperatureMeta =
      const VerificationMeta('temperature');
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
      'temperature', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _carbonMeta = const VerificationMeta('carbon');
  @override
  late final GeneratedColumn<int> carbon = GeneratedColumn<int>(
      'carbon', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _conductivityMeta =
      const VerificationMeta('conductivity');
  @override
  late final GeneratedColumn<int> conductivity = GeneratedColumn<int>(
      'conductivity', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lightMeta = const VerificationMeta('light');
  @override
  late final GeneratedColumn<int> light = GeneratedColumn<int>(
      'light', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sensorId,
        timestamp,
        battery,
        moisture,
        temperature,
        carbon,
        conductivity,
        light
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sensor_data';
  @override
  VerificationContext validateIntegrity(Insertable<SensorDataDao> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sensor_id')) {
      context.handle(_sensorIdMeta,
          sensorId.isAcceptableOrUnknown(data['sensor_id']!, _sensorIdMeta));
    } else if (isInserting) {
      context.missing(_sensorIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('battery')) {
      context.handle(_batteryMeta,
          battery.isAcceptableOrUnknown(data['battery']!, _batteryMeta));
    }
    if (data.containsKey('moisture')) {
      context.handle(_moistureMeta,
          moisture.isAcceptableOrUnknown(data['moisture']!, _moistureMeta));
    }
    if (data.containsKey('temperature')) {
      context.handle(
          _temperatureMeta,
          temperature.isAcceptableOrUnknown(
              data['temperature']!, _temperatureMeta));
    }
    if (data.containsKey('carbon')) {
      context.handle(_carbonMeta,
          carbon.isAcceptableOrUnknown(data['carbon']!, _carbonMeta));
    }
    if (data.containsKey('conductivity')) {
      context.handle(
          _conductivityMeta,
          conductivity.isAcceptableOrUnknown(
              data['conductivity']!, _conductivityMeta));
    }
    if (data.containsKey('light')) {
      context.handle(
          _lightMeta, light.isAcceptableOrUnknown(data['light']!, _lightMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SensorDataDao map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SensorDataDao(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sensorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sensor_id'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      battery: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}battery']),
      moisture: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}moisture']),
      temperature: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}temperature']),
      carbon: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}carbon']),
      conductivity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}conductivity']),
      light: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}light']),
    );
  }

  @override
  $SensorDataTable createAlias(String alias) {
    return $SensorDataTable(attachedDatabase, alias);
  }
}

class SensorDataDao extends DataClass implements Insertable<SensorDataDao> {
  final int id;
  final int sensorId;
  final DateTime timestamp;
  final double? battery;
  final double? moisture;
  final double? temperature;
  final int? carbon;
  final int? conductivity;
  final int? light;
  const SensorDataDao(
      {required this.id,
      required this.sensorId,
      required this.timestamp,
      this.battery,
      this.moisture,
      this.temperature,
      this.carbon,
      this.conductivity,
      this.light});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sensor_id'] = Variable<int>(sensorId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || battery != null) {
      map['battery'] = Variable<double>(battery);
    }
    if (!nullToAbsent || moisture != null) {
      map['moisture'] = Variable<double>(moisture);
    }
    if (!nullToAbsent || temperature != null) {
      map['temperature'] = Variable<double>(temperature);
    }
    if (!nullToAbsent || carbon != null) {
      map['carbon'] = Variable<int>(carbon);
    }
    if (!nullToAbsent || conductivity != null) {
      map['conductivity'] = Variable<int>(conductivity);
    }
    if (!nullToAbsent || light != null) {
      map['light'] = Variable<int>(light);
    }
    return map;
  }

  SensorDataCompanion toCompanion(bool nullToAbsent) {
    return SensorDataCompanion(
      id: Value(id),
      sensorId: Value(sensorId),
      timestamp: Value(timestamp),
      battery: battery == null && nullToAbsent
          ? const Value.absent()
          : Value(battery),
      moisture: moisture == null && nullToAbsent
          ? const Value.absent()
          : Value(moisture),
      temperature: temperature == null && nullToAbsent
          ? const Value.absent()
          : Value(temperature),
      carbon:
          carbon == null && nullToAbsent ? const Value.absent() : Value(carbon),
      conductivity: conductivity == null && nullToAbsent
          ? const Value.absent()
          : Value(conductivity),
      light:
          light == null && nullToAbsent ? const Value.absent() : Value(light),
    );
  }

  factory SensorDataDao.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SensorDataDao(
      id: serializer.fromJson<int>(json['id']),
      sensorId: serializer.fromJson<int>(json['sensorId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      battery: serializer.fromJson<double?>(json['battery']),
      moisture: serializer.fromJson<double?>(json['moisture']),
      temperature: serializer.fromJson<double?>(json['temperature']),
      carbon: serializer.fromJson<int?>(json['carbon']),
      conductivity: serializer.fromJson<int?>(json['conductivity']),
      light: serializer.fromJson<int?>(json['light']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sensorId': serializer.toJson<int>(sensorId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'battery': serializer.toJson<double?>(battery),
      'moisture': serializer.toJson<double?>(moisture),
      'temperature': serializer.toJson<double?>(temperature),
      'carbon': serializer.toJson<int?>(carbon),
      'conductivity': serializer.toJson<int?>(conductivity),
      'light': serializer.toJson<int?>(light),
    };
  }

  SensorDataDao copyWith(
          {int? id,
          int? sensorId,
          DateTime? timestamp,
          Value<double?> battery = const Value.absent(),
          Value<double?> moisture = const Value.absent(),
          Value<double?> temperature = const Value.absent(),
          Value<int?> carbon = const Value.absent(),
          Value<int?> conductivity = const Value.absent(),
          Value<int?> light = const Value.absent()}) =>
      SensorDataDao(
        id: id ?? this.id,
        sensorId: sensorId ?? this.sensorId,
        timestamp: timestamp ?? this.timestamp,
        battery: battery.present ? battery.value : this.battery,
        moisture: moisture.present ? moisture.value : this.moisture,
        temperature: temperature.present ? temperature.value : this.temperature,
        carbon: carbon.present ? carbon.value : this.carbon,
        conductivity:
            conductivity.present ? conductivity.value : this.conductivity,
        light: light.present ? light.value : this.light,
      );
  @override
  String toString() {
    return (StringBuffer('SensorDataData(')
          ..write('id: $id, ')
          ..write('sensorId: $sensorId, ')
          ..write('timestamp: $timestamp, ')
          ..write('battery: $battery, ')
          ..write('moisture: $moisture, ')
          ..write('temperature: $temperature, ')
          ..write('carbon: $carbon, ')
          ..write('conductivity: $conductivity, ')
          ..write('light: $light')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sensorId, timestamp, battery, moisture,
      temperature, carbon, conductivity, light);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SensorDataDao &&
          other.id == this.id &&
          other.sensorId == this.sensorId &&
          other.timestamp == this.timestamp &&
          other.battery == this.battery &&
          other.moisture == this.moisture &&
          other.temperature == this.temperature &&
          other.carbon == this.carbon &&
          other.conductivity == this.conductivity &&
          other.light == this.light);
}

class SensorDataCompanion extends UpdateCompanion<SensorDataDao> {
  final Value<int> id;
  final Value<int> sensorId;
  final Value<DateTime> timestamp;
  final Value<double?> battery;
  final Value<double?> moisture;
  final Value<double?> temperature;
  final Value<int?> carbon;
  final Value<int?> conductivity;
  final Value<int?> light;
  const SensorDataCompanion({
    this.id = const Value.absent(),
    this.sensorId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.battery = const Value.absent(),
    this.moisture = const Value.absent(),
    this.temperature = const Value.absent(),
    this.carbon = const Value.absent(),
    this.conductivity = const Value.absent(),
    this.light = const Value.absent(),
  });
  SensorDataCompanion.insert({
    this.id = const Value.absent(),
    required int sensorId,
    required DateTime timestamp,
    this.battery = const Value.absent(),
    this.moisture = const Value.absent(),
    this.temperature = const Value.absent(),
    this.carbon = const Value.absent(),
    this.conductivity = const Value.absent(),
    this.light = const Value.absent(),
  })  : sensorId = Value(sensorId),
        timestamp = Value(timestamp);
  static Insertable<SensorDataDao> custom({
    Expression<int>? id,
    Expression<int>? sensorId,
    Expression<DateTime>? timestamp,
    Expression<double>? battery,
    Expression<double>? moisture,
    Expression<double>? temperature,
    Expression<int>? carbon,
    Expression<int>? conductivity,
    Expression<int>? light,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sensorId != null) 'sensor_id': sensorId,
      if (timestamp != null) 'timestamp': timestamp,
      if (battery != null) 'battery': battery,
      if (moisture != null) 'moisture': moisture,
      if (temperature != null) 'temperature': temperature,
      if (carbon != null) 'carbon': carbon,
      if (conductivity != null) 'conductivity': conductivity,
      if (light != null) 'light': light,
    });
  }

  SensorDataCompanion copyWith(
      {Value<int>? id,
      Value<int>? sensorId,
      Value<DateTime>? timestamp,
      Value<double?>? battery,
      Value<double?>? moisture,
      Value<double?>? temperature,
      Value<int?>? carbon,
      Value<int?>? conductivity,
      Value<int?>? light}) {
    return SensorDataCompanion(
      id: id ?? this.id,
      sensorId: sensorId ?? this.sensorId,
      timestamp: timestamp ?? this.timestamp,
      battery: battery ?? this.battery,
      moisture: moisture ?? this.moisture,
      temperature: temperature ?? this.temperature,
      carbon: carbon ?? this.carbon,
      conductivity: conductivity ?? this.conductivity,
      light: light ?? this.light,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sensorId.present) {
      map['sensor_id'] = Variable<int>(sensorId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (battery.present) {
      map['battery'] = Variable<double>(battery.value);
    }
    if (moisture.present) {
      map['moisture'] = Variable<double>(moisture.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (carbon.present) {
      map['carbon'] = Variable<int>(carbon.value);
    }
    if (conductivity.present) {
      map['conductivity'] = Variable<int>(conductivity.value);
    }
    if (light.present) {
      map['light'] = Variable<int>(light.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SensorDataCompanion(')
          ..write('id: $id, ')
          ..write('sensorId: $sensorId, ')
          ..write('timestamp: $timestamp, ')
          ..write('battery: $battery, ')
          ..write('moisture: $moisture, ')
          ..write('temperature: $temperature, ')
          ..write('carbon: $carbon, ')
          ..write('conductivity: $conductivity, ')
          ..write('light: $light')
          ..write(')'))
        .toString();
  }
}

class $InitialSensorDataTable extends InitialSensorData
    with TableInfo<$InitialSensorDataTable, InitialSensorDataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InitialSensorDataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sensorIdMeta =
      const VerificationMeta('sensorId');
  @override
  late final GeneratedColumn<int> sensorId = GeneratedColumn<int>(
      'sensor_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _initialMeta =
      const VerificationMeta('initial');
  @override
  late final GeneratedColumn<DateTime> initial = GeneratedColumn<DateTime>(
      'initial', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [sensorId, initial];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'initial_sensor_data';
  @override
  VerificationContext validateIntegrity(
      Insertable<InitialSensorDataData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sensor_id')) {
      context.handle(_sensorIdMeta,
          sensorId.isAcceptableOrUnknown(data['sensor_id']!, _sensorIdMeta));
    } else if (isInserting) {
      context.missing(_sensorIdMeta);
    }
    if (data.containsKey('initial')) {
      context.handle(_initialMeta,
          initial.isAcceptableOrUnknown(data['initial']!, _initialMeta));
    } else if (isInserting) {
      context.missing(_initialMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sensorId, initial};
  @override
  InitialSensorDataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InitialSensorDataData(
      sensorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sensor_id'])!,
      initial: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}initial'])!,
    );
  }

  @override
  $InitialSensorDataTable createAlias(String alias) {
    return $InitialSensorDataTable(attachedDatabase, alias);
  }
}

class InitialSensorDataData extends DataClass
    implements Insertable<InitialSensorDataData> {
  final int sensorId;
  final DateTime initial;
  const InitialSensorDataData({required this.sensorId, required this.initial});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sensor_id'] = Variable<int>(sensorId);
    map['initial'] = Variable<DateTime>(initial);
    return map;
  }

  InitialSensorDataCompanion toCompanion(bool nullToAbsent) {
    return InitialSensorDataCompanion(
      sensorId: Value(sensorId),
      initial: Value(initial),
    );
  }

  factory InitialSensorDataData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InitialSensorDataData(
      sensorId: serializer.fromJson<int>(json['sensorId']),
      initial: serializer.fromJson<DateTime>(json['initial']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sensorId': serializer.toJson<int>(sensorId),
      'initial': serializer.toJson<DateTime>(initial),
    };
  }

  InitialSensorDataData copyWith({int? sensorId, DateTime? initial}) =>
      InitialSensorDataData(
        sensorId: sensorId ?? this.sensorId,
        initial: initial ?? this.initial,
      );
  @override
  String toString() {
    return (StringBuffer('InitialSensorDataData(')
          ..write('sensorId: $sensorId, ')
          ..write('initial: $initial')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sensorId, initial);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InitialSensorDataData &&
          other.sensorId == this.sensorId &&
          other.initial == this.initial);
}

class InitialSensorDataCompanion
    extends UpdateCompanion<InitialSensorDataData> {
  final Value<int> sensorId;
  final Value<DateTime> initial;
  final Value<int> rowid;
  const InitialSensorDataCompanion({
    this.sensorId = const Value.absent(),
    this.initial = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InitialSensorDataCompanion.insert({
    required int sensorId,
    required DateTime initial,
    this.rowid = const Value.absent(),
  })  : sensorId = Value(sensorId),
        initial = Value(initial);
  static Insertable<InitialSensorDataData> custom({
    Expression<int>? sensorId,
    Expression<DateTime>? initial,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sensorId != null) 'sensor_id': sensorId,
      if (initial != null) 'initial': initial,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InitialSensorDataCompanion copyWith(
      {Value<int>? sensorId, Value<DateTime>? initial, Value<int>? rowid}) {
    return InitialSensorDataCompanion(
      sensorId: sensorId ?? this.sensorId,
      initial: initial ?? this.initial,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sensorId.present) {
      map['sensor_id'] = Variable<int>(sensorId.value);
    }
    if (initial.present) {
      map['initial'] = Variable<DateTime>(initial.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InitialSensorDataCompanion(')
          ..write('sensorId: $sensorId, ')
          ..write('initial: $initial, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FetchHistoriesTable extends FetchHistories
    with TableInfo<$FetchHistoriesTable, FetchHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FetchHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sensorIdMeta =
      const VerificationMeta('sensorId');
  @override
  late final GeneratedColumn<int> sensorId = GeneratedColumn<int>(
      'sensor_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<DateTime> day = GeneratedColumn<DateTime>(
      'day', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [sensorId, day];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fetch_histories';
  @override
  VerificationContext validateIntegrity(Insertable<FetchHistory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sensor_id')) {
      context.handle(_sensorIdMeta,
          sensorId.isAcceptableOrUnknown(data['sensor_id']!, _sensorIdMeta));
    } else if (isInserting) {
      context.missing(_sensorIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
          _dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sensorId, day};
  @override
  FetchHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FetchHistory(
      sensorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sensor_id'])!,
      day: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}day'])!,
    );
  }

  @override
  $FetchHistoriesTable createAlias(String alias) {
    return $FetchHistoriesTable(attachedDatabase, alias);
  }
}

class FetchHistory extends DataClass implements Insertable<FetchHistory> {
  final int sensorId;
  final DateTime day;
  const FetchHistory({required this.sensorId, required this.day});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sensor_id'] = Variable<int>(sensorId);
    map['day'] = Variable<DateTime>(day);
    return map;
  }

  FetchHistoriesCompanion toCompanion(bool nullToAbsent) {
    return FetchHistoriesCompanion(
      sensorId: Value(sensorId),
      day: Value(day),
    );
  }

  factory FetchHistory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FetchHistory(
      sensorId: serializer.fromJson<int>(json['sensorId']),
      day: serializer.fromJson<DateTime>(json['day']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sensorId': serializer.toJson<int>(sensorId),
      'day': serializer.toJson<DateTime>(day),
    };
  }

  FetchHistory copyWith({int? sensorId, DateTime? day}) => FetchHistory(
        sensorId: sensorId ?? this.sensorId,
        day: day ?? this.day,
      );
  @override
  String toString() {
    return (StringBuffer('FetchHistory(')
          ..write('sensorId: $sensorId, ')
          ..write('day: $day')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sensorId, day);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FetchHistory &&
          other.sensorId == this.sensorId &&
          other.day == this.day);
}

class FetchHistoriesCompanion extends UpdateCompanion<FetchHistory> {
  final Value<int> sensorId;
  final Value<DateTime> day;
  final Value<int> rowid;
  const FetchHistoriesCompanion({
    this.sensorId = const Value.absent(),
    this.day = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FetchHistoriesCompanion.insert({
    required int sensorId,
    required DateTime day,
    this.rowid = const Value.absent(),
  })  : sensorId = Value(sensorId),
        day = Value(day);
  static Insertable<FetchHistory> custom({
    Expression<int>? sensorId,
    Expression<DateTime>? day,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sensorId != null) 'sensor_id': sensorId,
      if (day != null) 'day': day,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FetchHistoriesCompanion copyWith(
      {Value<int>? sensorId, Value<DateTime>? day, Value<int>? rowid}) {
    return FetchHistoriesCompanion(
      sensorId: sensorId ?? this.sensorId,
      day: day ?? this.day,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sensorId.present) {
      map['sensor_id'] = Variable<int>(sensorId.value);
    }
    if (day.present) {
      map['day'] = Variable<DateTime>(day.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FetchHistoriesCompanion(')
          ..write('sensorId: $sensorId, ')
          ..write('day: $day, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$SharedDatabase extends GeneratedDatabase {
  _$SharedDatabase(QueryExecutor e) : super(e);
  late final $SensorDataTable sensorData = $SensorDataTable(this);
  late final $InitialSensorDataTable initialSensorData =
      $InitialSensorDataTable(this);
  late final $FetchHistoriesTable fetchHistories = $FetchHistoriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [sensorData, initialSensorData, fetchHistories];
}
