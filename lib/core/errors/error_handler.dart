import 'package:flutter/foundation.dart';

import 'app_exception.dart';

/// 统一错误处理工具类
class ErrorHandler {
  /// 将错误转换为用户友好的消息
  static String getUserFriendlyMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }

    if (error is Exception) {
      final message = error.toString();
      // 移除 "Exception: " 前缀
      return message.replaceAll('Exception: ', '').replaceAll('Exception', '');
    }

    return error.toString();
  }

  /// 记录错误日志
  static void logError(dynamic error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// 根据错误码获取错误消息
  static String getErrorMessageByCode(int code) {
    const errorMessages = {
      400: '请求参数错误',
      401: '未授权访问，请重新登录',
      403: '权限不足',
      404: '资源不存在',
      500: '服务器内部错误',
      5001: '模型服务错误',
    };

    return errorMessages[code] ?? '未知错误';
  }

  /// 判断是否为网络错误
  static bool isNetworkError(dynamic error) {
    return error is NetworkException ||
        error.toString().contains('SocketException') ||
        error.toString().contains('TimeoutException');
  }

  /// 判断是否为认证错误
  static bool isAuthError(dynamic error) {
    return error is AuthException || 
        (error is AppException && error.code == 401);
  }
}
