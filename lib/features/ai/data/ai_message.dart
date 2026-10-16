/// Role of a chat message in the conversation.
enum AiRole { system, user, assistant }

/// A single chat message exchanged with the AI provider.
class AiMessage {
  final AiRole role;
  final String content;
  final DateTime timestamp;

  AiMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => role == AiRole.user;

  Map<String, dynamic> toJson() => {
        'role': role.name,
        'content': content,
        'ts': timestamp.millisecondsSinceEpoch,
      };

  factory AiMessage.fromJson(Map<dynamic, dynamic> j) => AiMessage(
        role: AiRole.values.firstWhere((e) => e.name == j['role'],
            orElse: () => AiRole.assistant),
        content: j['content'] as String? ?? '',
        timestamp:
            DateTime.fromMillisecondsSinceEpoch((j['ts'] as int?) ?? 0),
      );
}
