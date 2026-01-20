/// 应用异常基类
class AppException implements Exception {
  final String message;
  final int? code;
  final dynamic originalError;

  AppException(
    this.message, [
    this.code,
    this.originalError,
  ]);

  @override
  String toString() => message;
}

/// API异常
class ApiException extends AppException {
  ApiException(super.message, [super.code, super.originalError]);
}

/// 网络异常
class NetworkException extends AppException {
  NetworkException(super.message, [super.code, super.originalError]);
}

/// 认证异常
class AuthException extends AppException {
  AuthException(super.message, [super.code, super.originalError]);
}

/// 数据解析异常
class ParseException extends AppException {
  ParseException(super.message, [super.code, super.originalError]);
}
