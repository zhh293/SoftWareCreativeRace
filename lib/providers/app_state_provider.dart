import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateProvider with ChangeNotifier {
  // 用户状态
  String? _userId;
  String? _accessToken;
  String? _nickname;
  String? _email;
  
  // 应用状态
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  String? get userId => _userId;
  String? get accessToken => _accessToken;
  String? get nickname => _nickname;
  String? get email => _email;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // 计算属性
  bool get isAuthenticated => _accessToken != null && _userId != null;

  AppStateProvider() {
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _accessToken = prefs.getString('access_token');
      _userId = prefs.getString('user_id');
      _nickname = prefs.getString('nickname');
      _email = prefs.getString('email');
      
      _isInitialized = true;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> login(String userId, String accessToken, String nickname, String email) async {
    _userId = userId;
    _accessToken = accessToken;
    _nickname = nickname;
    _email = email;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('user_id', userId);
    await prefs.setString('nickname', nickname);
    await prefs.setString('email', email);
    
    notifyListeners();
  }

  Future<void> logout() async {
    _userId = null;
    _accessToken = null;
    _nickname = null;
    _email = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_id');
    await prefs.remove('nickname');
    await prefs.remove('email');
    
    notifyListeners();
  }

  Future<void> updateUserInfo({String? nickname, String? email}) async {
    if (nickname != null) _nickname = nickname;
    if (email != null) _email = email;
    
    final prefs = await SharedPreferences.getInstance();
    if (nickname != null) await prefs.setString('nickname', nickname);
    if (email != null) await prefs.setString('email', email);
    
    notifyListeners();
  }

  // 清除错误信息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}