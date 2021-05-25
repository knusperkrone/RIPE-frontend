import 'package:json_annotation/json_annotation.dart';

part 'dto.g.dart';

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
}

@JsonSerializable(createToJson: false, createFactory: false)
class AgentDecoratorDto {
  final Map<String, dynamic> payload;

  AgentDecoratorDto(this.payload);

  factory AgentDecoratorDto.fromJson(Map<String, dynamic> json) =>
      new AgentDecoratorDto(json);
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
}

@JsonSerializable(createToJson: false)
class AgentRenderDto {
  final AgentDecoratorDto decorator;
  final AgentStateDto state;
  final String rendered;

  AgentRenderDto(this.decorator, this.state, this.rendered);

  factory AgentRenderDto.fromJson(Map<String, dynamic> json) =>
      _$AgentRenderDtoFromJson(json);
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
}

@JsonSerializable(createToJson: false)
class SensorDto {
  final String name;
  final String broker;
  @JsonKey(name: 'data')
  final SensorDataDto sensorData;
  final List<AgentDto> agents;

  SensorDto(this.name, this.broker, this.sensorData, this.agents);

  factory SensorDto.fromJson(Map<String, dynamic> json) =>
      _$SensorDtoFromJson(json);
}
