class Message {
  final String messageId;
  final String conversationId;
  final String role;
  final String content;
  final int tokensUsed;
  final DateTime createdAt;
  final String? parentId;
  final List<String>? relatedIds;
  final Map<String, dynamic>? metadata;

  Message({
    required this.messageId,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.tokensUsed,
    required this.createdAt,
    this.parentId,
    this.relatedIds,
    this.metadata,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['message_id'] as String,
      conversationId: json['conversation_id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      tokensUsed: json['tokens_used'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      parentId: json['parent_id'] as String?,
      relatedIds: json['related_ids'] != null
          ? List<String>.from(json['related_ids'] as List)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'conversation_id': conversationId,
      'role': role,
      'content': content,
      'tokens_used': tokensUsed,
      'created_at': createdAt.toIso8601String(),
      if (parentId != null) 'parent_id': parentId,
      if (relatedIds != null) 'related_ids': relatedIds,
      if (metadata != null) 'metadata': metadata,
    };
  }

  Message copyWith({
    String? messageId,
    String? conversationId,
    String? role,
    String? content,
    int? tokensUsed,
    DateTime? createdAt,
    String? parentId,
    List<String>? relatedIds,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      messageId: messageId ?? this.messageId,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      tokensUsed: tokensUsed ?? this.tokensUsed,
      createdAt: createdAt ?? this.createdAt,
      parentId: parentId ?? this.parentId,
      relatedIds: relatedIds ?? this.relatedIds,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  bool get isSystem => role == 'system';
}

class SendMessageRequest {
  final String role;
  final String content;
  final bool stream;

  SendMessageRequest({
    required this.role,
    required this.content,
    this.stream = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'stream': stream,
    };
  }
}

class MessageResponse {
  final String messageId;
  final String conversationId;
  final String role;
  final String content;
  final int tokensUsed;
  final DateTime createdAt;

  MessageResponse({
    required this.messageId,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.tokensUsed,
    required this.createdAt,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    // 处理嵌套的 data 结构
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return MessageResponse(
      messageId: data['message_id'] as String,
      conversationId: data['conversation_id'] as String,
      role: data['role'] as String,
      content: data['content'] as String,
      tokensUsed: data['tokens_used'] as int? ?? 0,
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'message_id': messageId,
        'conversation_id': conversationId,
        'role': role,
        'content': content,
        'tokens_used': tokensUsed,
        'created_at': createdAt.toIso8601String(),
      },
    };
  }
}

class MessageListResponse {
  final List<Message> messages;
  final int total;
  final int page;
  final int pageSize;

  MessageListResponse({
    required this.messages,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory MessageListResponse.fromJson(Map<String, dynamic> json) {
    // 处理嵌套的 data 结构
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return MessageListResponse(
      messages: (data['messages'] as List?)
              ?.map((msg) => Message.fromJson(msg as Map<String, dynamic>))
              .toList() ??
          [],
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? 1,
      pageSize: data['page_size'] as int? ?? 20,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'messages': messages.map((msg) => msg.toJson()).toList(),
        'total': total,
        'page': page,
        'page_size': pageSize,
      },
    };
  }
}

class MessageEditRequest {
  final String content;

  MessageEditRequest({
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }
}

class MessageDeleteResponse {
  final bool success;
  final String message;

  MessageDeleteResponse({
    required this.success,
    required this.message,
  });

  factory MessageDeleteResponse.fromJson(Map<String, dynamic> json) {
    // 处理嵌套的 data 结构
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return MessageDeleteResponse(
      success: data['success'] as bool,
      message: data['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'success': success,
        'message': message,
      },
    };
  }
}
