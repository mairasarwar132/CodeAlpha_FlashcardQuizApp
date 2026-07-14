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
        title: const Text('Flashcards'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.study),
            icon: const Icon(Icons.school_outlined),
            tooltip: 'Study',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(flashcardNotifierProvider.notifier).refresh(),
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 104),
      itemCount: flashcards.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _DashboardHeader(count: flashcards.length);
        }

        final flashcardIndex = index - 1;
        final flashcard = flashcards[flashcardIndex];

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
      messenger.showSnackBar(SnackBar(content: Text(state.error.toString())));
      return;
    }

    messenger.showSnackBar(const SnackBar(content: Text('Flashcard deleted.')));
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flashcard Quiz App',
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Build momentum with quick, focused review sessions.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.78,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Text(
                  '$count',
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  count == 1 ? 'card' : 'cards',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.18),
        Center(
          child: Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              Icons.auto_stories_outlined,
              size: 42,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'No flashcards yet',
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Add your first question and answer to start studying.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 96),
        Icon(Icons.error_outline, size: 48, color: colorScheme.error),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ),
      ],
    );
  }
}
