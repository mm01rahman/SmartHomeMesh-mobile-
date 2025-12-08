/// MQTT broker configuration including TLS parameters.
class MqttBrokerConfig {
  final String host;
  final int port;
  final String clientId;
  final String topicPrefix;
  final String? username;
  final String? password;
  final String? caCertificate;
  final bool allowInsecure;
  final bool useTls;

  const MqttBrokerConfig({
    required this.host,
    this.port = 8883,
    this.clientId = 'smarthomemesh_app',
    this.topicPrefix = 'smarthomemesh',
    this.username,
    this.password,
    this.caCertificate,
    this.allowInsecure = false,
    this.useTls = true,
  });

  String get cmdTopic => '$topicPrefix/cmd';
  String get statusTopic => '$topicPrefix/status';
  String get ackTopic => '$topicPrefix/ack';
  String get joinTopic => '$topicPrefix/join';
  String get lwtTopic => '$topicPrefix/lwt';
}
