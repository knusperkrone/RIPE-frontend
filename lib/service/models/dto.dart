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

@JsonSerializable(createToJson: false)
class SensorDataDto {
  final DateTime timestamp;
  final double? battery;
  final double? moisture;
  final double? temperature;
  final int? carbon;
  final int? conductivity;
  final int? light;

  SensorDataDto(
    this.timestamp,
    this.battery,
    this.moisture,
    this.temperature,
    this.carbon,
    this.conductivity,
    this.light,
  );

  factory SensorDataDto.fromJson(Map<String, dynamic> json) =>
      _$SensorDataDtoFromJson(json);

  bool isEmpty() {
    return battery == null &&
        moisture == null &&
        temperature == null &&
        carbon == null &&
        conductivity == null &&
        light == null;
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

@JsonSerializable(createToJson: false, createFactory: false)
class AgentDecoratorDto {
  final Map<String, dynamic> payload;

  AgentDecoratorDto(this.payload);

  factory AgentDecoratorDto.fromJson(Map<String, dynamic> json) =>
      new AgentDecoratorDto(json);

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

  AgentStateDto(dynamic json) {
    if (json is String) {
      if (json == 'Disabled') {
        _state = AgentState.DISABLED;
      } else if (json == 'Ready') {
        _state = AgentState.READY;
      } else if (json == 'Error') {
        _state = AgentState.ERROR;
      } else {
        throw StateError('Invalid json value: $json');
      }
    } else if (json is Map<String, dynamic>) {
      final key = json.keys.first;
      if (key == 'Executing') {
        _state = AgentState.EXECUTING;
      } else if (key == 'Stopped') {
        _state = AgentState.STOPPED;
      } else if (key == 'Forced') {
        _state = AgentState.FORCED;
      } else {
        throw StateError('Invalid json value: $json');
      }
      _time = DateTime.parse(json.values.first as String);
    }
  }

  factory AgentStateDto.fromJson(dynamic json) => new AgentStateDto(json);

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

@JsonSerializable(createToJson: false)
class AgentRenderDto {
  final AgentDecoratorDto decorator;
  final AgentStateDto state;
  final String rendered;

  AgentRenderDto(this.decorator, this.state, this.rendered);

  factory AgentRenderDto.fromJson(Map<String, dynamic> json) =>
      _$AgentRenderDtoFromJson(json);

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

@JsonSerializable(createToJson: false)
class AgentDto {
  final String domain;
  @JsonKey(name: 'agent_name')
  final String agentName;
  final AgentRenderDto ui;

  AgentDto(this.domain, this.agentName, this.ui);

  factory AgentDto.fromJson(Map<String, dynamic> json) {
    return _$AgentDtoFromJson(json);
  }

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

@JsonSerializable(createToJson: false)
class BrokerDto {
  @JsonKey()
  final String? tcp;
  @JsonKey()
  final String? wss;

  BrokerDto({this.tcp, this.wss});

  factory BrokerDto.fromJson(Map<String, dynamic> json) =>
      _$BrokerDtoFromJson(json);

  @override
  int get hashCode {
    return tcp.hashCode * wss.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is BrokerDto) {
      return hashCode == other.hashCode;
    }
    return false;
  }
}

@JsonSerializable(createToJson: false)
class SensorDto {
  @JsonKey(required: false)
  final BrokerDto broker;
  @JsonKey(name: 'data')
  final SensorDataDto sensorData;
  final List<AgentDto> agents;

  SensorDto(this.broker, this.sensorData, this.agents);

  factory SensorDto.fromJson(Map<String, dynamic> json) =>
      _$SensorDtoFromJson(json);

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
