import 'package:ai_study_helper/models/mindmap_node.dart';

class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;
  final DateTime timestamp;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
  }) : timestamp = DateTime.now();

  factory ApiResponse.fromJson(Map<String, dynamic> json, [Function(dynamic)? fromJson]) {
    return ApiResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'] != null && fromJson != null ? fromJson(json['data']) : json['data'],
    );
  }

  Map<String, dynamic> toJson([Function(T)? toJson]) {
    return {
      'code': code,
      'message': message,
      'data': data != null && toJson != null ? toJson(data!) : data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isSuccess => code == 0;

  String get errorMessage => message;

  @override
  String toString() {
    return 'ApiResponse{code: $code, message: $message, data: $data, timestamp: $timestamp}';
  }
}

class AuthResponse {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final UserResponse user;

  AuthResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['data']['access_token'] as String,
      tokenType: json['data']['token_type'] as String,
      expiresIn: json['data']['expires_in'] as int,
      user: UserResponse.fromJson(json['data']['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'access_token': accessToken,
        'token_type': tokenType,
        'expires_in': expiresIn,
        'user': user.toJson(),
      },
    };
  }
}

class UserResponse {
  final String userId;
  final String email;
  final String? nickname;
  final String? avatarUrl;
  final DateTime createdAt;
  final Map<String, dynamic>? preferences;

  UserResponse({
    required this.userId,
    required this.email,
    this.nickname,
    this.avatarUrl,
    required this.createdAt,
    this.preferences,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      userId: json['user_id'] as String,
      email: json['email'] as String,
      nickname: json['nickname'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      if (nickname != null) 'nickname': nickname,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      if (preferences != null) 'preferences': preferences,
    };
  }
}

class ModelInfo {
  final String modelId;
  final String name;
  final String provider;
  final String description;
  final List<String> recommendedScenes;
  final int maxTokens;

  ModelInfo({
    required this.modelId,
    required this.name,
    required this.provider,
    required this.description,
    required this.recommendedScenes,
    required this.maxTokens,
  });

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      modelId: json['model_id'] as String,
      name: json['name'] as String,
      provider: json['provider'] as String,
      description: json['description'] as String,
      recommendedScenes: List<String>.from(json['recommended_scenes'] as List),
      maxTokens: json['max_tokens'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model_id': modelId,
      'name': name,
      'provider': provider,
      'description': description,
      'recommended_scenes': recommendedScenes,
      'max_tokens': maxTokens,
    };
  }
}

class PromptPreset {
  final String presetId;
  final String name;
  final String description;
  final String systemPrompt;
  final String defaultModelId;

  PromptPreset({
    required this.presetId,
    required this.name,
    required this.description,
    required this.systemPrompt,
    required this.defaultModelId,
  });

  factory PromptPreset.fromJson(Map<String, dynamic> json) {
    return PromptPreset(
      presetId: json['preset_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      systemPrompt: json['system_prompt'] as String,
      defaultModelId: json['default_model_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preset_id': presetId,
      'name': name,
      'description': description,
      'system_prompt': systemPrompt,
      'default_model_id': defaultModelId,
    };
  }
}

class ConversationResponse {
  final String conversationId;
  final String title;
  final String modelId;
  final String presetId;
  final DateTime createdAt;

  ConversationResponse({
    required this.conversationId,
    required this.title,
    required this.modelId,
    required this.presetId,
    required this.createdAt,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    return ConversationResponse(
      conversationId: json['data']['conversation_id'] as String,
      title: json['data']['title'] as String,
      modelId: json['data']['model_id'] as String,
      presetId: json['data']['preset_id'] as String,
      createdAt: DateTime.parse(json['data']['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'conversation_id': conversationId,
        'title': title,
        'model_id': modelId,
        'preset_id': presetId,
        'created_at': createdAt.toIso8601String(),
      },
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
    return MessageResponse(
      messageId: json['data']['message_id'] as String,
      conversationId: json['data']['conversation_id'] as String,
      role: json['data']['role'] as String,
      content: json['data']['content'] as String,
      tokensUsed: json['data']['tokens_used'] as int,
      createdAt: DateTime.parse(json['data']['created_at'] as String),
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

class ConversationListResponse {
  final List<ConversationResponse> items;
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
      items: (json['data']['items'] as List)
          .map((item) => ConversationResponse.fromJson({'data': item}))
          .toList(),
      page: json['data']['page'] as int,
      pageSize: json['data']['page_size'] as int,
      total: json['data']['total'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'items': items.map((item) => item.toJson()['data']).toList(),
        'page': page,
        'page_size': pageSize,
        'total': total,
      },
    };
  }
}

class MindMapResponse {
  final String mindmapId;
  final String title;
  final MindMapNode rootNode;
  final DateTime createdAt;

  MindMapResponse({
    required this.mindmapId,
    required this.title,
    required this.rootNode,
    required this.createdAt,
  });

  factory MindMapResponse.fromJson(Map<String, dynamic> json) {
    return MindMapResponse(
      mindmapId: json['data']['mindmap_id'] as String,
      title: json['data']['title'] as String,
      rootNode: MindMapNode.fromJson(json['data']['root_node'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['data']['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'mindmap_id': mindmapId,
        'title': title,
        'root_node': rootNode.toJson(),
        'created_at': createdAt.toIso8601String(),
      },
    };
  }
}
