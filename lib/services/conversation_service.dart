import 'package:flutter/foundation.dart';

import 'package:ai_study_helper/services/api_service.dart';
import 'package:ai_study_helper/models/conversation_model.dart';
import 'package:ai_study_helper/models/message_model.dart';
import 'package:ai_study_helper/services/auth_service.dart';

class ConversationService {
  static final ConversationService _instance = ConversationService._internal();
  factory ConversationService() => _instance;
  ConversationService._internal();

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  Future<Conversation?> createConversation({
    String? title,
    String? modelId,
    String? presetId,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('用户未登录');
      }

      final response = await _apiService.createConversation(
        token,
        title: title,
        modelId: modelId,
        presetId: presetId,
      );

      if (response.isSuccess && response.data != null) {
        return Conversation(
          conversationId: response.data!.conversationId,
          title: response.data!.title,
          modelId: response.data!.modelId,
          presetId: response.data!.presetId,
          createdAt: response.data!.createdAt,
          updatedAt: response.data!.createdAt,
        );
      }

      throw Exception(response.message);
    } catch (e) {
      debugPrint('Create conversation error: $e');
      rethrow;
    }
  }

  Future<List<Conversation>> getConversations({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('用户未登录');
      }

      final response = await _apiService.getConversations(token, page: page, pageSize: pageSize);

      if (response.isSuccess && response.data != null) {
        return response.data!.items;
      }

      throw Exception(response.message);
    } catch (e) {
      debugPrint('Get conversations error: $e');
      rethrow;
    }
  }

  Future<List<Message>> getConversationMessages(String conversationId) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('用户未登录');
      }

      final response = await _apiService.getConversationMessages(token, conversationId);

      if (response.isSuccess && response.data != null) {
        return response.data!.messages;
      }

      throw Exception(response.message);
    } catch (e) {
      debugPrint('Get conversation messages error: $e');
      rethrow;
    }
  }

  Future<Message?> sendMessage(String conversationId, String content) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('用户未登录');
      }

      final response = await _apiService.sendMessage(token, conversationId, content);

      if (response.isSuccess && response.data != null) {
        return Message(
          messageId: response.data!.messageId,
          conversationId: response.data!.conversationId,
          role: response.data!.role,
          content: response.data!.content,
          tokensUsed: response.data!.tokensUsed,
          createdAt: response.data!.createdAt,
        );
      }

      throw Exception(response.message);
    } catch (e) {
      debugPrint('Send message error: $e');
      rethrow;
    }
  }

  Future<bool> deleteConversation(String conversationId) async {
    // TODO: 实现删除会话功能
    return true;
  }

  Future<bool> updateConversation(String conversationId, {String? title}) async {
    // TODO: 实现更新会话功能
    return true;
  }

  Future<int> getConversationCount() async {
    try {
      final conversations = await getConversations(pageSize: 1);
      // 这里需要获取总数，可能需要修改API
      return conversations.length;
    } catch (e) {
      debugPrint('Get conversation count error: $e');
      return 0;
    }
  }

  Future<Conversation?> getConversationById(String conversationId) async {
    try {
      final conversations = await getConversations();
      return conversations.firstWhere((conv) => conv.conversationId == conversationId, orElse: () => throw Exception('Conversation not found'));
    } catch (e) {
      debugPrint('Get conversation by id error: $e');
      return null;
    }
  }
}