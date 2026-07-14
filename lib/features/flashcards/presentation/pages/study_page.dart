import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/entities/flashcard_entity.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/providers/flashcard_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudyPage extends ConsumerStatefulWidget {
  const StudyPage({super.key});

  @override
  ConsumerState<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends ConsumerState<StudyPage> {
  int _currentIndex = 0;
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    final flashcardsState = ref.watch(flashcardNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Study Session')),
      body: SafeArea(
        child: flashcardsState.when(
          data: _buildContent,
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

  Widget _buildContent(List<FlashcardEntity> flashcards) {
    if (flashcards.isEmpty) {
      return const _StudyEmptyState();
    }

    final lastIndex = flashcards.length - 1;
    final safeIndex = _currentIndex.clamp(0, lastIndex).toInt();

    if (safeIndex != _currentIndex) {
      _currentIndex = safeIndex;
    }

    final flashcard = flashcards[_currentIndex];
    final progress = (_currentIndex + 1) / flashcards.length;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 44),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Card ${_currentIndex + 1} of ${flashcards.length}',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.school_outlined, color: colorScheme.primary),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 28),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  constraints: const BoxConstraints(minHeight: 300),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: colorScheme.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.10),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            _showAnswer
                                ? Icons.lightbulb_outline
                                : Icons.help_outline,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          flashcard.question,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 24),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(
                                  begin: 0.96,
                                  end: 1,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: _showAnswer
                              ? Text(
                                  flashcard.answer,
                                  key: ValueKey(flashcard.answer),
                                  textAlign: TextAlign.center,
                                  style: textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.35,
                                  ),
                                )
                              : FilledButton.icon(
                                  key: const ValueKey('show-answer'),
                                  onPressed: () =>
                                      setState(() => _showAnswer = true),
                                  icon: const Icon(Icons.visibility_outlined),
                                  label: const Text('Show Answer'),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _currentIndex == 0 ? null : _previous,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _currentIndex == lastIndex ? null : _next,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _previous() {
    if (_currentIndex == 0) {
      return;
    }

    setState(() {
      _currentIndex--;
      _showAnswer = false;
    });
  }

  void _next() {
    final flashcards = ref.read(flashcardNotifierProvider).asData?.value;
    final lastIndex = (flashcards?.length ?? 1) - 1;

    if (_currentIndex >= lastIndex) {
      return;
    }

    setState(() {
      _currentIndex++;
      _showAnswer = false;
    });
  }
}

class _StudyEmptyState extends StatelessWidget {
  const _StudyEmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.menu_book_outlined,
                size: 42,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No flashcards to study',
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Create flashcards first, then return here for a focused review.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
