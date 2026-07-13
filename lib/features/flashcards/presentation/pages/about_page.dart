import 'package:codealpha_flashcard_quiz_app/core/constants/app_strings.dart';
import 'package:codealpha_flashcard_quiz_app/core/widgets/placeholder_page.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(title: AppStrings.aboutTitle);
  }
}
