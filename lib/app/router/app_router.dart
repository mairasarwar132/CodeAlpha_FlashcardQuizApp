import 'package:codealpha_flashcard_quiz_app/app/router/app_shell.dart';
import 'package:codealpha_flashcard_quiz_app/core/constants/app_strings.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/pages/about_page.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/pages/add_flashcard_page.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/pages/edit_flashcard_page.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/pages/home_page.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/pages/settings_page.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/pages/statistics_page.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/pages/study_page.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  overridePlatformDefaultLocation: true,
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              name: AppRouteNames.home,
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.study,
              name: AppRouteNames.study,
              builder: (context, state) => const StudyPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.statistics,
              name: AppRouteNames.statistics,
              builder: (context, state) => const StatisticsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              name: AppRouteNames.settings,
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.addFlashcard,
      name: AppRouteNames.addFlashcard,
      builder: (context, state) => const AddFlashcardPage(),
    ),
    GoRoute(
      path: AppRoutes.editFlashcard,
      name: AppRouteNames.editFlashcard,
      builder: (context, state) {
        final flashcardId = int.tryParse(state.pathParameters['id'] ?? '');

        return EditFlashcardPage(flashcardId: flashcardId ?? -1);
      },
    ),
    GoRoute(
      path: AppRoutes.about,
      name: AppRouteNames.about,
      builder: (context, state) => const AboutPage(),
    ),
  ],
);

abstract final class AppRoutes {
  static const String home = '/home';
  static const String study = '/study';
  static const String statistics = '/statistics';
  static const String addFlashcard = '/flashcards/add';
  static const String editFlashcard = '/flashcards/edit/:id';
  static const String settings = '/settings';
  static const String about = '/about';
}

abstract final class AppRouteNames {
  static const String home = AppStrings.homeTitle;
  static const String study = AppStrings.studyTitle;
  static const String statistics = AppStrings.statisticsTitle;
  static const String addFlashcard = AppStrings.addFlashcardTitle;
  static const String editFlashcard = AppStrings.editFlashcardTitle;
  static const String settings = AppStrings.settingsTitle;
  static const String about = AppStrings.aboutTitle;
}
