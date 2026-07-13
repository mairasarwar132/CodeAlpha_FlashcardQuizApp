import 'package:codealpha_flashcard_quiz_app/core/constants/app_spacing.dart';
import 'package:codealpha_flashcard_quiz_app/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.homeTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.homeHeading,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalMedium,
              Text(
                AppStrings.foundationComplete,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalLarge,
              const ElevatedButton(
                onPressed: null,
                child: Text(AppStrings.placeholderButtonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
