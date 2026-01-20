import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:ai_study_helper/providers/app_state_provider.dart';
import 'package:ai_study_helper/theme/app_theme.dart';
import 'package:ai_study_helper/routes/app_routes.dart';

class App extends StatelessWidget {
  App({super.key});

  final GoRouter _router = AppRoutes.router;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ],
      child: MaterialApp.router(
        title: 'AI 学习助手',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: _router,
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(
              physics: const BouncingScrollPhysics(),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}