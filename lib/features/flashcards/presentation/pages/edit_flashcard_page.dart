import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/entities/flashcard_entity.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/providers/flashcard_notifier.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/widgets/flashcard_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditFlashcardPage extends ConsumerWidget {
  const EditFlashcardPage({
    required this.flashcardId,
    super.key,
  });

  final int flashcardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashcardsState = ref.watch(flashcardNotifierProvider);

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
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: FlashcardForm(
                  key: ValueKey(flashcard.id),
                  initialQuestion: flashcard.question,
                  initialAnswer: flashcard.answer,
                  submitLabel: 'Save Changes',
                  onSubmit: (question, answer) async {
                    await ref
                        .read(flashcardNotifierProvider.notifier)
                        .updateFlashcard(
                          FlashcardEntity(
                            id: flashcard.id,
                            question: question,
                            answer: answer,
                            createdAt: flashcard.createdAt,
                            updatedAt: DateTime.now(),
                          ),
                        );

                    if (!context.mounted) {
                      return;
                    }

                    final state = ref.read(flashcardNotifierProvider);
                    final messenger = ScaffoldMessenger.of(context);

                    if (state.hasError) {
                      messenger.showSnackBar(
                        SnackBar(content: Text(state.error.toString())),
                      );
                      return;
                    }

                    messenger.showSnackBar(
                      const SnackBar(content: Text('Flashcard updated.')),
                    );
                    Navigator.of(context).pop();
                  },
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
