import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:ai_study_helper/screens/splash_screen.dart';
import 'package:ai_study_helper/screens/auth/login_screen.dart';
import 'package:ai_study_helper/screens/auth/register_screen.dart';
import 'package:ai_study_helper/screens/main_home_screen.dart';
import 'package:ai_study_helper/screens/chat/chat_screen.dart';
import 'package:ai_study_helper/screens/mindmap/mindmap_viewer_screen.dart';
import 'package:ai_study_helper/providers/app_state_provider.dart';

class AppRoutes {
  static GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (BuildContext context, GoRouterState state) {
      // 临时关闭路由守卫，允许直接访问所有页面
      // final appState = context.read<AppStateProvider>();
      
      // // 如果还在初始化，停留在启动页
      // if (!appState.isInitialized) {
      //   return '/splash';
      // }
      
      // // 如果已登录，跳转到主页
      // if (appState.isAuthenticated) {
      //   final currentPath = state.uri.path;
      //   if (currentPath == '/splash' || currentPath == '/login' || currentPath == '/register') {
      //     return '/home';
      //   }
      // } else {
      //   // 如果未登录，只能访问登录、注册页面
      //   final currentPath = state.uri.path;
      //   if (currentPath != '/splash' && currentPath != '/login' && currentPath != '/register') {
      //     return '/login';
      //   }
      // }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainHomeScreen(),
        routes: [
          GoRoute(
            path: 'chat/:conversationId',
            name: 'chat',
            builder: (context, state) {
              final conversationId = state.pathParameters['conversationId']!;
              return ChatScreen(conversationId: conversationId);
            },
          ),
          GoRoute(
            path: 'mindmap/:mindmapId',
            name: 'mindmap',
            builder: (context, state) {
              final mindmapId = state.pathParameters['mindmapId']!;
              return MindMapViewScreen(mindmapId: mindmapId);
            },
          ),
        ],
      ),
    ],
  );
}