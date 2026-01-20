class User {
  final String userId;
  final String email;
  final String? nickname;
  final String? avatarUrl;
  final DateTime createdAt;
  final Map<String, dynamic>? preferences;

  User({
    required this.userId,
    required this.email,
    this.nickname,
    this.avatarUrl,
    required this.createdAt,
    this.preferences,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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

  User copyWith({
    String? userId,
    String? email,
    String? nickname,
    String? avatarUrl,
    DateTime? createdAt,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
    );
  }
}

class UserProfile {
  final String userId;
  final String email;
  final String? nickname;
  final String? avatarUrl;
  final Map<String, dynamic> preferences;
  final DateTime lastActiveAt;
  final int totalConversations;
  final int totalMindMaps;

  UserProfile({
    required this.userId,
    required this.email,
    this.nickname,
    this.avatarUrl,
    required this.preferences,
    required this.lastActiveAt,
    required this.totalConversations,
    required this.totalMindMaps,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as String,
      email: json['email'] as String,
      nickname: json['nickname'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      preferences: json['preferences'] as Map<String, dynamic>? ?? {},
      lastActiveAt: DateTime.parse(json['last_active_at'] as String),
      totalConversations: json['total_conversations'] as int? ?? 0,
      totalMindMaps: json['total_mind_maps'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      if (nickname != null) 'nickname': nickname,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'preferences': preferences,
      'last_active_at': lastActiveAt.toIso8601String(),
      'total_conversations': totalConversations,
      'total_mind_maps': totalMindMaps,
    };
  }

  UserProfile copyWith({
    String? userId,
    String? email,
    String? nickname,
    String? avatarUrl,
    Map<String, dynamic>? preferences,
    DateTime? lastActiveAt,
    int? totalConversations,
    int? totalMindMaps,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      preferences: preferences ?? this.preferences,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      totalConversations: totalConversations ?? this.totalConversations,
      totalMindMaps: totalMindMaps ?? this.totalMindMaps,
    );
  }
}

class UpdateUserProfileRequest {
  final String? nickname;
  final String? avatarUrl;
  final Map<String, dynamic>? preferences;

  UpdateUserProfileRequest({
    this.nickname,
    this.avatarUrl,
    this.preferences,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (nickname != null) map['nickname'] = nickname;
    if (avatarUrl != null) map['avatar_url'] = avatarUrl;
    if (preferences != null) map['preferences'] = preferences;
    return map;
  }
}
