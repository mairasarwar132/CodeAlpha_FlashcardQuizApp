import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/entities/flashcard_entity.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/providers/flashcard_notifier.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/widgets/flashcard_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditFlashcardPage extends ConsumerWidget {
  const EditFlashcardPage({required this.flashcardId, super.key});

  final int flashcardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashcardsState = ref.watch(flashcardNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Flashcard')),
      body: SafeArea(
        child: flashcardsState.when(
          data: (flashcards) {
            final flashcard = _findFlashcard(flashcards);

            if (flashcard == null) {
              return const Center(child: Text('Flashcard not found.'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _EditHero(colorScheme: colorScheme, textTheme: textTheme),
                      const SizedBox(height: 18),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: FlashcardForm(
                            key: ValueKey(flashcard.id),
                            initialQuestion: flashcard.question,
                            initialAnswer: flashcard.answer,
                            initialCategory: flashcard.category,
                            initialIsFavorite: flashcard.isFavorite,
                            submitLabel: 'Save Changes',
                            onSubmit:
                                (question, answer, category, isFavorite) async {
                                  await ref
                                      .read(flashcardNotifierProvider.notifier)
                                      .updateFlashcard(
                                        FlashcardEntity(
                                          id: flashcard.id,
                                          question: question,
                                          answer: answer,
                                          category: category,
                                          isFavorite: isFavorite,
                                          createdAt: flashcard.createdAt,
                                          updatedAt: DateTime.now(),
                                        ),
                                      );

                                  if (!context.mounted) {
                                    return;
                                  }

                                  final state = ref.read(
                                    flashcardNotifierProvider,
                                  );
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );

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
                                      message: 'Flashcard updated.',
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
            );
          },
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(error.toString(), textAlign: TextAlign.center),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  FlashcardEntity? _findFlashcard(List<FlashcardEntity> flashcards) {
    for (final flashcard in flashcards) {
      if (flashcard.id == flashcardId) {
        return flashcard;
      }
    }

    return null;
  }
}

class _EditHero extends StatelessWidget {
  const _EditHero({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
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
            child: Icon(Icons.edit_note_outlined, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Refine this flashcard',
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Improve clarity so the card is easier to remember later.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSecondaryContainer.withValues(
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
