import 'package:codealpha_flashcard_quiz_app/app/router/app_router.dart';
import 'package:codealpha_flashcard_quiz_app/app/theme/app_theme.dart';
import 'package:codealpha_flashcard_quiz_app/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
