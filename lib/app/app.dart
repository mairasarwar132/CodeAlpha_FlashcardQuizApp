import 'package:codealpha_flashcard_quiz_app/app/router/app_router.dart';
import 'package:codealpha_flashcard_quiz_app/app/theme/app_theme.dart';
import 'package:codealpha_flashcard_quiz_app/app/theme/theme_mode_provider.dart';
import 'package:codealpha_flashcard_quiz_app/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
