import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ai_study_helper/app.dart';
import 'package:ai_study_helper/services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化ApiService
  ApiService().init();
  
  // 设置系统UI样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // 锁定竖屏
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(App());
}