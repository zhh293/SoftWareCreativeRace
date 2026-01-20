import 'package:ai_study_helper/models/message_model.dart';

class Conversation {
  final String conversationId;
  final String title;
  final String modelId;
  final String presetId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastMessageSummary;
  final int messageCount;

  Conversation({
    required this.conversationId,
    required this.title,
    required this.modelId,
    required this.presetId,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageSummary,
    this.messageCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      conversationId: json['conversation_id'] as String,
      title: json['title'] as String,
      modelId: json['model_id'] as String,
      presetId: json['preset_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastMessageSummary: json['last_message_summary'] as String?,
      messageCount: json['message_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'title': title,
      'model_id': modelId,
      'preset_id': presetId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (lastMessageSummary != null) 'last_message_summary': lastMessageSummary,
      'message_count': messageCount,
    };
  }

  Conversation copyWith({
    String? conversationId,
    String? title,
    String? modelId,
    String? presetId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessageSummary,
    int? messageCount,
  }) {
    return Conversation(
      conversationId: conversationId ?? this.conversationId,
      title: title ?? this.title,
      modelId: modelId ?? this.modelId,
      presetId: presetId ?? this.presetId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageSummary: lastMessageSummary ?? this.lastMessageSummary,
      messageCount: messageCount ?? this.messageCount,
    );
  }
}

class CreateConversationRequest {
  final String? title;
  final String? modelId;
  final String? presetId;

  CreateConversationRequest({
    this.title,
    this.modelId,
    this.presetId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (modelId != null) map['model_id'] = modelId;
    if (presetId != null) map['preset_id'] = presetId;
    return map;
  }
}

class ConversationListResponse {
  final List<Conversation> items;
  final int page;
  final int pageSize;
  final int total;

  ConversationListResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  factory ConversationListResponse.fromJson(Map<String, dynamic> json) {
    return ConversationListResponse(
      items: (json['items'] as List?)
              ?.map((item) => Conversation.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'page': page,
      'page_size': pageSize,
      'total': total,
    };
  }
}

class ConversationDetailResponse {
  final Conversation conversation;
  final List<Message> messages;

  ConversationDetailResponse({
    required this.conversation,
    required this.messages,
  });

  factory ConversationDetailResponse.fromJson(Map<String, dynamic> json) {
    return ConversationDetailResponse(
      conversation: Conversation.fromJson(json['conversation'] as Map<String, dynamic>),
      messages: (json['messages'] as List?)
              ?.map((message) => Message.fromJson(message as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation': conversation.toJson(),
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }
}
