class MessageModel {
  final String sender;
  final String receiver;
  final String content;
  final String timestamp;
  final int isSent; // 1 sent, 0 received

  MessageModel({
    required this.sender,
    required this.receiver,
    required this.content,
    required this.timestamp,
    required this.isSent,
  });

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'receiver': receiver,
      'content': content,
      'timestamp': timestamp,
      'isSent': isSent,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      sender: map['sender'],
      receiver: map['receiver'],
      content: map['content'],
      timestamp: map['timestamp'],
      isSent: map['isSent'],
    );
  }
}
