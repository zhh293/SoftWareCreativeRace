import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:ai_study_helper/core/config/api_config.dart';
import 'package:ai_study_helper/models/api_response.dart' as ApiResp;
import 'package:ai_study_helper/models/conversation_model.dart' as ConvModel;
import 'package:ai_study_helper/models/message_model.dart' as MsgModel;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;

  static const Map<int, String> _errorMessages = {
    400: '请求参数错误',
    401: '未授权访问',
    403: '权限不足',
    404: '资源不存在',
    500: '服务器内部错误',
  };

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: {
        ApiConfig.contentTypeHeader: ApiConfig.applicationJson,
      },
    ));

    // 添加拦截器
    _dio.interceptors.add(LogInterceptor(
      requestBody: kDebugMode,
      responseBody: kDebugMode,
    ));
  }

  // 认证相关
  Future<ApiResp.ApiResponse<ApiResp.AuthResponse>> register(String email, String password, {String? nickname, String? invitationCode}) async {
    try {
      final response = await _dio.post(
        ApiConfig.registerPath,
        data: {
          'email': email,
          'password': password,
          if (nickname != null) 'nickname': nickname,
          if (invitationCode != null) 'invitation_code': invitationCode,
        },
      );
      
      return ApiResp.ApiResponse.fromJson(response.data, (data) => ApiResp.AuthResponse.fromJson({'data': data}));
    } on DioException catch (e) {
      return ApiResp.ApiResponse(
        code: e.response?.statusCode ?? 500,
        message: e.response?.data['message'] ?? _errorMessages[e.response?.statusCode] ?? '注册失败',
        data: null,
      );
    }
  }

  Future<ApiResp.ApiResponse<ApiResp.AuthResponse>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.loginPath,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      return ApiResp.ApiResponse.fromJson(response.data, (data) => ApiResp.AuthResponse.fromJson({'data': data}));
    } on DioException catch (e) {
      return ApiResp.ApiResponse(
        code: e.response?.statusCode ?? 500,
        message: e.response?.data['message'] ?? _errorMessages[e.response?.statusCode] ?? '登录失败',
        data: null,
      );
    }
  }

  Future<ApiResp.ApiResponse<ApiResp.UserResponse>> getUserInfo(String token) async {
    try {
      final response = await _dio.get(
        ApiConfig.mePath,
        options: Options(headers: {
          ApiConfig.authorizationHeader: '${ApiConfig.bearerTokenPrefix}$token',
        }),
      );
      
      return ApiResp.ApiResponse.fromJson(response.data, (data) => ApiResp.UserResponse.fromJson(data));
    } on DioException catch (e) {
      return ApiResp.ApiResponse(
        code: e.response?.statusCode ?? 500,
        message: e.response?.data['message'] ?? _errorMessages[e.response?.statusCode] ?? '获取用户信息失败',
        data: null,
      );
    }
  }

  Future<ApiResp.ApiResponse<ApiResp.UserResponse>> updateUserInfo(String token, {String? nickname, String? avatarUrl, Map<String, dynamic>? preferences}) async {
    try {
      final response = await _dio.put(
        ApiConfig.mePath,
        data: {
          if (nickname != null) 'nickname': nickname,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
          if (preferences != null) 'preferences': preferences,
        },
        options: Options(headers: {
          ApiConfig.authorizationHeader: '${ApiConfig.bearerTokenPrefix}$token',
        }),
      );
      
      return ApiResp.ApiResponse.fromJson(response.data, (data) => ApiResp.UserResponse.fromJson(data));
    } on DioException catch (e) {
      return ApiResp.ApiResponse(
        code: e.response?.statusCode ?? 500,
        message: e.response?.data['message'] ?? _errorMessages[e.response?.statusCode] ?? '更新用户信息失败',
        data: null,
      );
    }
  }

  // 模型相关
  Future<ApiResp.ApiResponse<List<ApiResp.ModelInfo>>> getModels(String token) async {
    try {
      final response = await _dio.get(
        ApiConfig.modelsListPath,
        options: Options(headers: {
          ApiConfig.authorizationHeader: '${ApiConfig.bearerTokenPrefix}$token',
        }),
      );
      
      final models = (response.data['data'] as List)
          .map((json) => ApiResp.ModelInfo.fromJson(json))
          .toList();
      
      return ApiResp.ApiResponse(
        code: 0,
        message: '获取模型列表成功',
        data: models,
      );
    } on DioException catch (e) {
      return ApiResp.ApiResponse(
        code: e.response?.statusCode ?? 500,
        message: e.response?.data['message'] ?? _errorMessages[e.response?.statusCode] ?? '获取模型列表失败',
        data: null,
      );
    }
  }

  Future<ApiResp.ApiResponse<List<ApiResp.PromptPreset>>> getPromptPresets(String token) async {
    try {
      final response = await _dio.get(
        ApiConfig.promptPresetsListPath,
        options: Options(headers: {
          ApiConfig.authorizationHeader: '${ApiConfig.bearerTokenPrefix}$token',
        }),
      );
      
      final presets = (response.data['data'] as List)
          .map((json) => ApiResp.PromptPreset.fromJson(json))
          .toList();
      
      return ApiResp.ApiResponse(
        code: 0,
        message: '获取提示词预设成功',
        data: presets,
      );
    } on DioException catch (e) {
      return ApiResp.ApiResponse(
        code: e.response?.statusCode ?? 500,
        message: e.response?.data['message'] ?? _errorMessages[e.response?.statusCode] ?? '获取提示词预设失败',
        data: null,
      );
    }
  }

  // 会话相关
  Future<ApiResp.ApiResponse<ApiResp.ConversationResponse>> createConversation(String token, {String? title, String? modelId, String? presetId}) async {
    try {
      final response = await _dio.post(
        ApiConfig.conversationsListPath,
        data: {
          if (title != null) 'title': title,
          if (modelId != null) 'model_id': modelId,
          if (presetId != null) 'preset_id': presetId,
        },
        options: Options(headers: {
          ApiConfig.authorizationHeader: '${ApiConfig.bearerTokenPrefix}$token',
        }),
      );
      
      return ApiResp.ApiResponse.fromJson(response.data, (data) => ApiResp.ConversationResponse.fromJson({'data': data}));
    } on DioException catch (e) {
      return ApiResp.ApiResponse(
        code: e.response?.statusCode ?? 500,
        message: e.response?.data['message'] ?? _errorMessages[e.response?.statusCode] ?? '创建会话失败',
        data: null,
      );
    }
  }

  Future<ApiResp.ApiResponse<ConvModel.ConversationListResponse>> getConversations(String token, {int page = 1, int pageSize = 20}) async {  // 使用别名
    try {
      final response = await _dio.get(
        ApiConfig.conversationsListPath,
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
        options: Options(headers: {
          ApiConfig.authorizationHeader: '${ApiConfig.bearerTokenPrefix}$token',
        }),
      );
      
      return ApiResp.ApiResponse.fromJson(response.data, (data) => ConvModel.ConversationListResponse.fromJson(data));
    } on DioException catch (e) {
      return ApiResp.ApiResponse(
        code: e.response?.statusCode ?? 500,
        message: e.response?.data['message'] ?? _errorMessages[e.response?.statusCode] ?? '获取会话列表失败',
        data: null,
      );
    }
  }

  Future<ApiResp.ApiResponse<ConvModel.ConversationDetailResponse>> getConversationMessages(String token, String conversationId) async {  // 使用别名
    try {
      final response = await _dio.get(
        ApiConfig.conversationMessagesPath(conversationId),
        options: Options(headers: {
          ApiConfig.authorizationHeader: '${ApiConfig.bearerTokenPrefix}$token',
        }),
      );
      
      return ApiResp.ApiResponse.fromJson(response.data, (data) => ConvModel.ConversationDetailResponse.fromJson(data));
    } on DioException catch (e) {
      return ApiResp.ApiResponse(
        code: e.response?.statusCode ?? 500,
        message: e.response?.data['message'] ?? _errorMessages[e.response?.statusCode] ?? '获取会话消息失败',
        data: null,
      );
    }
  }
Future<ApiResp.ApiResponse<MsgModel.MessageResponse>> sendMessage(String token, String conversationId, String content) async {  // 使用别名
    try {
      final response = await _dio.post(
        ApiConfig.conversationMessagesPath(conversationId),
        data: {
          'role': 'user',
          'content': content,
          'stream': false,
        },
        options: Options(headers: {
          ApiConfig.authorizationHeader: '${ApiConfig.bearerTokenPrefix}$token',
        }),
      );
      
      return ApiResp.ApiResponse.fromJson(response.data, (data) => MsgModel.MessageResponse.fromJson({'data': data}));
    } on DioException catch (e) {
      return ApiResp.ApiResponse(
        code: e.response?.statusCode ?? 500,
        message: e.response?.data['message'] ?? _errorMessages[e.response?.statusCode] ?? '发送消息失败',
        data: null,
      );
    }
  }

  // 思维导图相关
  Future<ApiResp.ApiResponse<ApiResp.MindMapResponse>> generateMindMap(String token, String conversationId, {String? title}) async {
    try {
      final response = await _dio.post(
        ApiConfig.mindMapsListPath,
        data: {
          'conversation_id': conversationId,
          if (title != null) 'title': title,
        },
        options: Options(headers: {
          ApiConfig.authorizationHeader: '${ApiConfig.bearerTokenPrefix}$token',
        }),
      );
      
      return ApiResp.ApiResponse.fromJson(response.data, (data) => ApiResp.MindMapResponse.fromJson({'data': data}));
    } on DioException catch (e) {
      return ApiResp.ApiResponse(
        code: e.response?.statusCode ?? 500,
        message: e.response?.data['message'] ?? _errorMessages[e.response?.statusCode] ?? '生成思维导图失败',
        data: null,
      );
    }
  }

  Future<ApiResp.ApiResponse<ApiResp.MindMapResponse>> getMindMap(String token, String mindMapId) async {
    try {
      final response = await _dio.get(
        ApiConfig.mindMapDetailPath(mindMapId),
        options: Options(headers: {
          ApiConfig.authorizationHeader: '${ApiConfig.bearerTokenPrefix}$token',
        }),
      );
      
      return ApiResp.ApiResponse.fromJson(response.data, (data) => ApiResp.MindMapResponse.fromJson({'data': data}));
    } on DioException catch (e) {
      return ApiResp.ApiResponse(
        code: e.response?.statusCode ?? 500,
        message: e.response?.data['message'] ?? _errorMessages[e.response?.statusCode] ?? '获取思维导图失败',
        data: null,
      );
    }
  }

  // 健康检查
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get(ApiConfig.healthPath);
      return response.data['status'] == 'ok';
    } catch (e) {
      return false;
    }
  }

  // 错误处理
  String getErrorMessage(int statusCode) {
    return _errorMessages[statusCode] ?? '未知错误';
  }
}