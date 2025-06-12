import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../services/sqlite_service.dart';
import '../models/message_model.dart';

class MqttService {
  final String username; // digunakan sebagai topik pribadi
  final SQLiteService db;

  late MqttServerClient client;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  final String broker = '103.127.97.36';
  final String password = '100704';
  final String clientId;

  final StreamController<MessageModel> _messageController =
      StreamController<MessageModel>.broadcast();

  Stream<MessageModel> get messageStream => _messageController.stream;

  MqttService({required this.username, required this.db})
    : clientId = 'client_$username';

  Future<void> connect() async {
    client = MqttServerClient(broker, clientId);
    client.port = 1883;
    client.logging(on: true);
    client.keepAlivePeriod = 60;
    client.onDisconnected = onDisconnected;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .authenticateAs(username, password)
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;

    try {
      await client.connect().timeout(Duration(seconds: 10));
      if (client.connectionStatus!.state == MqttConnectionState.connected) {
        print('✅ MQTT connected');
        _isConnected = true;
        subscribe(username); // 📩 Subscribe ke topik pribadi
        listen();
      } else {
        print('❌ MQTT connection failed');
        _isConnected = false;
      }
    } on TimeoutException catch (_) {
      print('⚠️ MQTT connection timed out');
      _isConnected = false;
      client.disconnect();
    } catch (e) {
      print('⚠️ MQTT Exception: $e');
      _isConnected = false;
      client.disconnect();
    }
  }

  void subscribe(String topic) {
    if (_isConnected) {
      client.subscribe(topic, MqttQos.atLeastOnce);
    } else {
      print('⚠️ Cannot subscribe, MQTT client not connected');
    }
  }

  void listen() {
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) async {
      final message = c[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(
        message.payload.message,
      );

      final sender = c[0].topic;
      print('📥 Message from $sender: $payload');

      final msg = MessageModel(
        sender: sender,
        receiver: username,
        content: payload,
        timestamp: DateTime.now().toIso8601String(),
        isSent: 0,
      );

      await db.insertMessage(msg);
      _messageController.add(msg);
    });
  }

  void sendMessage(String to, String content) {
    if (!_isConnected) {
      print('⚠️ Cannot send message, MQTT client not connected');
      return;
    }

    final builder = MqttClientPayloadBuilder();
    builder.addString(content);

    client.publishMessage(to, MqttQos.atLeastOnce, builder.payload!);

    final msg = MessageModel(
      sender: username,
      receiver: to,
      content: content,
      timestamp: DateTime.now().toIso8601String(),
      isSent: 1,
    );

    db.insertMessage(msg);
    _messageController.add(msg);
  }

  void onDisconnected() {
    print('❎ MQTT disconnected');
    _isConnected = false;
  }

  void dispose() {
    _messageController.close();
    client.disconnect();
  }
}
