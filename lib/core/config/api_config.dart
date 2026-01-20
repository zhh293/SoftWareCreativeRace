import 'package:flutter/foundation.dart';

enum Environment {
  dev, // 开发环境
  prod, // 生产环境
  local, // 本地环境
}

class ApiConfig {
  // 当前环境
  static Environment _currentEnvironment = Environment.dev;

  static void setEnvironment(Environment env) {
    _currentEnvironment = env;
  }

  // 各环境 Base URL
  static const String _devBaseUrl = 'https://api.ai-study-helper.com/api/v1';
  static const String _prodBaseUrl = 'https://api.ai-study-helper.com/api/v1';
  static const String _localBaseUrl = 'http://127.0.0.1:8000/api/v1';

  // 基础配置
  static String get baseUrl {
    switch (_currentEnvironment) {
      case Environment.dev:
        return _devBaseUrl;
      case Environment.prod:
        return _prodBaseUrl;
      case Environment.local:
        return _localBaseUrl;
    }
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Headers
  static const String authorizationHeader = 'Authorization';
  static const String bearerTokenPrefix = 'Bearer ';
  static const String contentTypeHeader = 'content-type';
  static const String applicationJson = 'application/json';

  // 模块前缀
  static const String authPrefix = '/auth';
  static const String userPrefix = '/users';
  static const String modelsPath = '/models';
  static const String promptPresetsPath = '/prompt-presets';
  static const String conversationsPath = '/conversations';
  static const String mindMapsPath = '/mindmaps';
  static const String notesPath = '/notes';
  static const String healthPath = '/health';
  static const String versionPath = '/version';

  // 认证相关接口
  static String get loginPath => '$authPrefix/login';
  static String get registerPath => '$authPrefix/register';
  static String get mePath => '$userPrefix/me';

  // 模型相关接口
  static String get modelsListPath => modelsPath;
  static String get promptPresetsListPath => promptPresetsPath;

  // 会话相关接口
  static String get conversationsListPath => conversationsPath;

  /// 获取会话消息列表 [GET] / 发送消息 [POST]
  static String conversationMessagesPath(String conversationId) =>
      '$conversationsPath/$conversationId/messages';

  static String conversationDetailPath(String conversationId) =>
      '$conversationsPath/$conversationId';

  // 思维导图相关接口
  static String get mindMapsListPath => mindMapsPath;
  static String mindMapDetailPath(String mindMapId) =>
      '$mindMapsPath/$mindMapId';

  // 笔记相关接口
  static String get notesListPath => notesPath;
  static String noteDetailPath(String noteId) => '$notesPath/$noteId';

  // 错误码定义
  static const int paramErrorCode = 4001;
  static const int unauthorizedCode = 4003;
  static const int notFoundCode = 4004;
  static const int forbiddenCode = 4005;
  static const int internalServerErrorCode = 5000;
  static const int modelServiceErrorCode = 5001;
}
