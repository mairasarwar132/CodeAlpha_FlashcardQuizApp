import 'package:codealpha_flashcard_quiz_app/app/router/app_router.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/entities/flashcard_entity.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/providers/flashcard_notifier.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/widgets/flashcard_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashcardsState = ref.watch(flashcardNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard Quiz App'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.study),
            icon: const Icon(Icons.school_outlined),
            tooltip: 'Study',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(flashcardNotifierProvider.notifier).refresh(),
        child: flashcardsState.when(
          data: (flashcards) => _FlashcardList(flashcards: flashcards),
          error: (error, stackTrace) => _ErrorView(
            message: error.toString(),
            onRetry: () =>
                ref.read(flashcardNotifierProvider.notifier).loadFlashcards(),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addFlashcard),
        icon: const Icon(Icons.add),
        label: const Text('Add Flashcard'),
      ),
    );
  }
}

class _FlashcardList extends ConsumerWidget {
  const _FlashcardList({required this.flashcards});

  final List<FlashcardEntity> flashcards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (flashcards.isEmpty) {
      return const _EmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: flashcards.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final flashcard = flashcards[index];

        return FlashcardCard(
          flashcard: flashcard,
          onStudy: () => context.push(AppRoutes.study),
          onEdit: () => context.push('/flashcards/edit/${flashcard.id}'),
          onDelete: () => _confirmDelete(context, ref, flashcard),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    FlashcardEntity flashcard,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Flashcard'),
        content: const Text('Are you sure you want to delete this flashcard?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted || flashcard.id == null) {
      return;
    }

    await ref
        .read(flashcardNotifierProvider.notifier)
        .deleteFlashcard(flashcard.id!);

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
      const SnackBar(content: Text('Flashcard deleted.')),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.25),
        const Center(
          child: Text('No flashcards yet'),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 120),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ),
      ],
    );
  }
}
