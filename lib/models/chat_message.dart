class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final bool isError;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    this.isError = false,
    DateTime? timestamp,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'isError': isError,
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'],
        text: json['text'],
        isUser: json['isUser'],
        isError: json['isError'] ?? false,
        timestamp: DateTime.parse(json['timestamp']),
        metadata: json['metadata'],
      );
}
