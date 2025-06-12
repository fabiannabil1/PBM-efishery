import 'package:flutter/material.dart';
import '../../services/sqlite_service.dart';
import '../../services/mqtt_service.dart';
import '../../models/message_model.dart';
import '../../widgets/chat/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String currentUsername;
  final String targetUsername;

  const ChatScreen({
    Key? key,
    required this.currentUsername,
    required this.targetUsername,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SQLiteService _db = SQLiteService();
  late MqttService _mqttService;
  final TextEditingController _controller = TextEditingController();

  List<MessageModel> _messages = [];

  @override
  void initState() {
    super.initState();
    _mqttService = MqttService(username: widget.currentUsername, db: _db);
    _mqttService.messageStream.listen((msg) {
      if ((msg.sender == widget.currentUsername &&
              msg.receiver == widget.targetUsername) ||
          (msg.sender == widget.targetUsername &&
              msg.receiver == widget.currentUsername)) {
        setState(() {
          _messages.add(msg);
          _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        });
      }
    });
    _initChat();
  }

  void _initChat() async {
    await _mqttService.connect();
    await _loadMessages();
  }

  Future<void> _loadMessages() async {
    final messages = await _db.getMessages(
      widget.currentUsername,
      widget.targetUsername,
    );

    setState(() {
      _messages = messages;
    });
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (!_mqttService.isConnected) {
      print('⚠️ MQTT client not connected, cannot send message');
      return;
    }

    _mqttService.sendMessage(widget.targetUsername, text);
    _controller.clear();

    // Optimistically add the sent message to the list
    final msg = MessageModel(
      sender: widget.currentUsername,
      receiver: widget.targetUsername,
      content: text,
      timestamp: DateTime.now().toIso8601String(),
      isSent: 1,
    );
    setState(() {
      _messages.add(msg);
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with ${widget.targetUsername}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return ChatBubble(
                  message: message,
                  isMe: message.sender == widget.currentUsername,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ketik pesan...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
