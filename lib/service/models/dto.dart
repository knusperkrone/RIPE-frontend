import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dto.g.dart';

const _LIST_EQ = ListEquality<dynamic>();

enum AgentState {
  DISABLED,
  READY,
  EXECUTING,
  STOPPED,
  FORCED,
  ERROR,
}

@JsonSerializable()
class SensorDataDto {
  final DateTime timestamp;
  final double? battery;
  final double? moisture;
  final double? temperature;
  final double? humidity;
  final int? carbon;
  final int? conductivity;
  final int? light;

  SensorDataDto(
    this.timestamp,
    this.battery,
    this.moisture,
    this.temperature,
    this.humidity,
    this.carbon,
    this.conductivity,
    this.light,
  );

  factory SensorDataDto.fromJson(Map<String, dynamic> json) =>
      _$SensorDataDtoFromJson(json);

  SensorDataDto copyWith(
      {double? battery,
      double? moisture,
      double? temperature,
      double? humidity,
      int? carbon,
      int? conductivity,
      int? light}) {
    return new SensorDataDto(
        timestamp,
        battery ?? this.battery,
        moisture ?? this.moisture,
        temperature ?? this.temperature,
        humidity ?? this.humidity,
        carbon ?? this.carbon,
        conductivity ?? this.conductivity,
        light ?? this.light);
  }

  bool isEmpty() {
    return battery == null &&
        moisture == null &&
        temperature == null &&
        carbon == null &&
        conductivity == null &&
        light == null;
  }

  Map<String, dynamic> toJson() => _$SensorDataDtoToJson(this);

  int get fieldCount {
    int count = 0;
    if (battery != null) {
      count++;
    }
    if (moisture != null) {
      count++;
    }
    if (temperature != null) {
      count++;
    }
    if (carbon != null) {
      count++;
    }
    if (conductivity != null) {
      count++;
    }
    if (light != null) {
      count++;
    }
    return count;
  }

  @override
  int get hashCode {
    return timestamp.hashCode *
        battery.hashCode *
        moisture.hashCode *
        temperature.hashCode *
        carbon.hashCode *
        conductivity.hashCode *
        light.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is SensorDataDto) {
      return hashCode == other.hashCode;
    }
    return false;
  }
}

@JsonSerializable(createFactory: false, createToJson: false)
class AgentDecoratorDto {
  final Map<String, dynamic> payload;

  AgentDecoratorDto(this.payload);

  factory AgentDecoratorDto.fromJson(Map<String, dynamic> json) =>
      new AgentDecoratorDto(json);

  Map<String, dynamic> toJson() => payload;

  @override
  int get hashCode {
    return payload.entries.map((entry) {
      int valueHash = entry.value.hashCode;
      if (entry.value is List) {
        valueHash = _LIST_EQ.hash(entry.value as List).hashCode;
      }
      return entry.key.hashCode * valueHash;
    }).sum;
  }

  @override
  bool operator ==(Object other) {
    if (other is AgentDecoratorDto) {
      return hashCode == other.hashCode;
    }
    return false;
  }
}

class AgentStateDto {
  late AgentState _state;
  DateTime? _time;

  AgentStateDto(dynamic value) {
    if (value is String) {
      final key = value.toLowerCase();
      if (key == 'disabled') {
        _state = AgentState.DISABLED;
      } else if (key == 'ready') {
        _state = AgentState.READY;
      } else if (key == 'error') {
        _state = AgentState.ERROR;
      } else {
        throw StateError('Invalid json value: $value');
      }
    } else if (value is Map<String, dynamic>) {
      final key = value.keys.first.toLowerCase();
      if (key == 'executing') {
        _state = AgentState.EXECUTING;
      } else if (key == 'stopped') {
        _state = AgentState.STOPPED;
      } else if (key == 'forced') {
        _state = AgentState.FORCED;
      } else {
        throw StateError('Invalid json value: $value');
      }
      _time = DateTime.tryParse(value.values.first as String);
    }
  }

  static AgentStateDto fromJson(dynamic json) => new AgentStateDto(json);

  static dynamic toJson(AgentStateDto self) {
    if (self._time == null) {
      return self._state.name.toString();
    }
    return {self._state.name.toString(): self._time?.toString()};
  }

  bool get isReady => _state == AgentState.READY;

  bool get isActive =>
      _state == AgentState.EXECUTING || _state == AgentState.FORCED;

  bool get isForced =>
      _state == AgentState.STOPPED || _state == AgentState.FORCED;

  bool get isForcedOn => _state == AgentState.FORCED;

  bool get isForcedOff => _state == AgentState.STOPPED;

  AgentState get state => _state;

  DateTime? get time => _time;

  @override
  int get hashCode {
    return _state.hashCode * _time.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is AgentStateDto) {
      return hashCode == other.hashCode;
    }
    return false;
  }
}

@JsonSerializable(createToJson: true)
class AgentRenderDto {
  final AgentDecoratorDto decorator;
  @JsonKey(fromJson: AgentStateDto.fromJson, toJson: AgentStateDto.toJson)
  final AgentStateDto state;
  final String rendered;

  AgentRenderDto({
    required this.decorator,
    required this.rendered,
    required this.state,
  });

  factory AgentRenderDto.fromJson(Map<String, dynamic> json) =>
      _$AgentRenderDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AgentRenderDtoToJson(this);

  @override
  int get hashCode {
    return decorator.hashCode * state.hashCode * rendered.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is AgentRenderDto) {
      return hashCode == other.hashCode;
    }
    return false;
  }
}

@JsonSerializable()
class AgentDto {
  final String domain;
  @JsonKey(name: 'agent_name')
  final String agentName;
  final AgentRenderDto ui;

  AgentDto(this.domain, this.agentName, this.ui);

  factory AgentDto.fromJson(Map<String, dynamic> json) =>
      _$AgentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AgentDtoToJson(this);

  @override
  int get hashCode {
    return domain.hashCode * agentName.hashCode * ui.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is AgentDto) {
      return hashCode == other.hashCode;
    }
    return false;
  }
}

@JsonSerializable()
class BrokerCredentialsDto {
  final String username;
  final String password;

  BrokerCredentialsDto(this.username, this.password);

  factory BrokerCredentialsDto.fromJson(Map<String, dynamic> json) =>
      _$BrokerCredentialsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BrokerCredentialsDtoToJson(this);
}

@JsonSerializable()
class BrokerConnectionDetailsDto {
  final String scheme;
  final String host;
  final int port;
  final BrokerCredentialsDto? credentials;

  BrokerConnectionDetailsDto(
      this.scheme, this.host, this.port, this.credentials);

  factory BrokerConnectionDetailsDto.fromJson(Map<String, dynamic> json) =>
      _$BrokerConnectionDetailsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BrokerConnectionDetailsDtoToJson(this);

  @override
  int get hashCode {
    return scheme.hashCode * host.hashCode * port.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is BrokerConnectionDetailsDto) {
      return hashCode == other.hashCode;
    }
    return false;
  }
}

@JsonSerializable()
class BrokersDto {
  @JsonKey()
  final List<BrokerConnectionDetailsDto> items;

  BrokersDto(this.items);

  factory BrokersDto.fromJson(Map<String, dynamic> json) =>
      _$BrokersDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BrokersDtoToJson(this);

  @override
  int get hashCode {
    return _LIST_EQ.hash(items);
  }

  @override
  bool operator ==(Object other) {
    if (other is BrokersDto) {
      return hashCode == other.hashCode;
    }
    return false;
  }
}

@JsonSerializable()
class SensorDto {
  @JsonKey(required: false)
  final BrokersDto broker;
  @JsonKey(name: 'data')
  final SensorDataDto sensorData;
  final List<AgentDto> agents;

  SensorDto(this.broker, this.sensorData, this.agents);

  factory SensorDto.fromJson(Map<String, dynamic> json) =>
      _$SensorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SensorDtoToJson(this);

  @override
  int get hashCode {
    return broker.hashCode * sensorData.hashCode * _LIST_EQ.hash(agents);
  }

  @override
  bool operator ==(Object other) {
    if (other is SensorDto) {
      return hashCode == other.hashCode;
    }
    return false;
  }
}
