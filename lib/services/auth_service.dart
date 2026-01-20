import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_study_helper/services/api_service.dart';
import 'package:ai_study_helper/models/api_response.dart' as ApiResp;
import 'package:ai_study_helper/models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _tokenKey = 'access_token';
  static const String _userIdKey = 'user_id';
  static const String _userInfoKey = 'user_info';

  final ApiService _apiService = ApiService();

  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      
      if (response.isSuccess && response.data != null) {
        await _saveAuthData(
          response.data!.accessToken,
          response.data!.user.userId,
          response.data!.user,
        );
        return true;
      }
      
      throw Exception(response.message);
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  Future<bool> register(String email, String password, {String? nickname, String? invitationCode}) async {
    try {
      final response = await _apiService.register(email, password, 
        nickname: nickname, 
        invitationCode: invitationCode
      );
      
      if (response.isSuccess && response.data != null) {
        await _saveAuthData(
          response.data!.accessToken,
          response.data!.user.userId,
          response.data!.user,
        );
        return true;
      }
      
      throw Exception(response.message);
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoJson = prefs.getString(_userInfoKey);
    
    if (userInfoJson != null) {
      try {
        final userInfoMap = jsonDecode(userInfoJson) as Map<String, dynamic>;
        return User.fromJson(userInfoMap);
      } catch (e) {
        debugPrint('Error parsing user info: $e');
        return null;
      }
    }
    
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userInfoKey);
  }

  Future<void> _saveAuthData(String token, String userId, ApiResp.UserResponse userResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    
    // 保存用户信息 - 转换为 User 模型并序列化
    final user = User(
      userId: userResponse.userId,
      email: userResponse.email,
      nickname: userResponse.nickname,
      avatarUrl: userResponse.avatarUrl,
      createdAt: userResponse.createdAt,
      preferences: userResponse.preferences,
    );
    
    // 使用 User 模型的 toJson 方法进行序列化
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userInfoKey, userJson);
  }

  Future<bool> refreshToken() async {
    // TODO: 实现token刷新逻辑
    return await isLoggedIn();
  }
}
