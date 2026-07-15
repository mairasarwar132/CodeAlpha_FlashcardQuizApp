import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/providers/flashcard_notifier.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/widgets/flashcard_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddFlashcardPage extends ConsumerWidget {
  const AddFlashcardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Flashcard')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FormHero(
                    icon: Icons.add_card_outlined,
                    title: 'Create a new flashcard',
                    subtitle:
                        'Write a concise prompt and a memorable answer for future study sessions.',
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: FlashcardForm(
                        submitLabel: 'Save Flashcard',
                        onSubmit:
                            (question, answer, category, isFavorite) async {
                              await ref
                                  .read(flashcardNotifierProvider.notifier)
                                  .addFlashcard(
                                    question: question,
                                    answer: answer,
                                    category: category,
                                    isFavorite: isFavorite,
                                  );

                              if (!context.mounted) {
                                return;
                              }

                              final state = ref.read(flashcardNotifierProvider);
                              final messenger = ScaffoldMessenger.of(context);

                              if (state.hasError) {
                                messenger.showSnackBar(
                                  _buildSnackBar(
                                    context,
                                    message: state.error.toString(),
                                    icon: Icons.error_outline,
                                  ),
                                );
                                return;
                              }

                              messenger.showSnackBar(
                                _buildSnackBar(
                                  context,
                                  message: 'Flashcard saved.',
                                  icon: Icons.check_circle_outline,
                                ),
                              );
                              Navigator.of(context).pop();
                            },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormHero extends StatelessWidget {
  const _FormHero({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colorScheme,
    required this.textTheme,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.78,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

SnackBar _buildSnackBar(
  BuildContext context, {
  required String message,
  required IconData icon,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return SnackBar(
    content: Row(
      children: [
        Icon(icon, color: colorScheme.onInverseSurface),
        const SizedBox(width: 12),
        Expanded(child: Text(message)),
      ],
    ),
  );
}
