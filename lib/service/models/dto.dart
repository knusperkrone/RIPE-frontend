import 'package:json_annotation/json_annotation.dart';
import 'package:optional/optional.dart';
import 'package:tuple/tuple.dart';

part 'dto.g.dart';

@JsonSerializable(createToJson: false)
class SensorDataDto {
  final DateTime timestamp;
  final int battery;
  final int moisture;
  final double temperature;
  final int carbon;
  final int conductivity;
  final int light;

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

  AgentDecoratorDto(this.payload) : assert(payload != null);

  factory AgentDecoratorDto.fromJson(Map<String, dynamic> json) =>
      new AgentDecoratorDto(json);
}

class AgentStateDto {
  bool _isActive;
  bool _isDefault;
  Tuple2<bool, DateTime> _forced;

  AgentStateDto(dynamic json) {
    if (json is String) {
      if (json == 'Active') {
        _isActive = true;
      } else if (json == 'Default') {
        _isDefault = false;
      } else {
        throw StateError('Invalid json: $json');
      }
    } else {
      final payload = json['Forced'] as List<dynamic>;
      _forced = new Tuple2(
        payload[0] as bool,
        DateTime.parse(payload[1] as String),
      );
      assert(_forced.item1 != null && _forced.item2 != null);
    }
  }

  bool get isActive => _isActive ?? false;

  bool get isDefault => _isDefault ?? false;

  Optional<Tuple2<bool, DateTime>> get isForced => Optional.ofNullable(_forced);

  factory AgentStateDto.fromJson(dynamic json) => new AgentStateDto(json);
}

@JsonSerializable(createToJson: false)
class AgentRenderDto {
  final AgentDecoratorDto decorator;
  final AgentStateDto state;
  final String rendered;

  AgentRenderDto(this.decorator, this.state, this.rendered)
      : assert(decorator != null && state != null && rendered != null);

  factory AgentRenderDto.fromJson(Map<String, dynamic> json) =>
      _$AgentRenderDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class AgentDto {
  final String domain;
  @JsonKey(name: 'agent_name')
  final String agentName;
  final AgentRenderDto ui;

  AgentDto(this.domain, this.agentName, this.ui)
      : assert(domain != null && agentName != null && ui != null);

  factory AgentDto.fromJson(Map<String, dynamic> json) {
    return _$AgentDtoFromJson(json);
  }
}

@JsonSerializable(createToJson: false)
class SensorDto {
  final String name;
  @JsonKey(name: 'data')
  final SensorDataDto sensorData;
  final List<AgentDto> agents;

  SensorDto(this.name, this.sensorData, this.agents)
      : assert(name != null && sensorData != null && agents != null);

  factory SensorDto.fromJson(Map<String, dynamic> json) =>
      _$SensorDtoFromJson(json);
}
