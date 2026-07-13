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
      appBar: AppBar(title: const Text('Study')),
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
      return const Center(child: Text('No flashcards yet'));
    }

    final lastIndex = flashcards.length - 1;
    final safeIndex = _currentIndex.clamp(0, lastIndex).toInt();

    if (safeIndex != _currentIndex) {
      _currentIndex = safeIndex;
    }

    final flashcard = flashcards[_currentIndex];

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${_currentIndex + 1} / ${flashcards.length}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          flashcard.question,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 24),
                        if (_showAnswer)
                          Text(
                            flashcard.answer,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          )
                        else
                          FilledButton(
                            onPressed: () =>
                                setState(() => _showAnswer = true),
                            child: const Text('Show Answer'),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _currentIndex == 0 ? null : _previous,
                        child: const Text('Previous'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _currentIndex == lastIndex ? null : _next,
                        child: const Text('Next'),
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
