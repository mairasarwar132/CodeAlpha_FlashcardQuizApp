import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/providers/flashcard_notifier.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/widgets/flashcard_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddFlashcardPage extends ConsumerWidget {
  const AddFlashcardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Flashcard')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: FlashcardForm(
              submitLabel: 'Save',
              onSubmit: (question, answer) async {
                await ref
                    .read(flashcardNotifierProvider.notifier)
                    .addFlashcard(question: question, answer: answer);

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
                  const SnackBar(content: Text('Flashcard saved.')),
                );
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ),
    );
  }
}
