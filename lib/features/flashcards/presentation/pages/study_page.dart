import 'dart:math' as math;

import 'package:codealpha_flashcard_quiz_app/app/router/app_router.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/entities/flashcard_entity.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/providers/flashcard_notifier.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/providers/study_progress_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StudyPage extends ConsumerStatefulWidget {
  const StudyPage({super.key});

  @override
  ConsumerState<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends ConsumerState<StudyPage> {
  int _currentIndex = 0;
  bool _showAnswer = false;
  bool _shuffleMode = false;
  bool _completionShown = false;
  List<int> _order = const [];
  final Set<int> _studiedIndexes = {};
  final Set<int> _correctIndexes = {};

  @override
  Widget build(BuildContext context) {
    final flashcardsState = ref.watch(flashcardNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Session'),
        actions: [
          IconButton(
            onPressed: _toggleShuffle,
            icon: Icon(
              _shuffleMode ? Icons.shuffle_on_rounded : Icons.shuffle_rounded,
            ),
            tooltip: 'Shuffle mode',
          ),
        ],
      ),
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

    _ensureOrder(flashcards.length);
    final safeIndex = _currentIndex.clamp(0, flashcards.length - 1).toInt();
    if (safeIndex != _currentIndex) {
      _currentIndex = safeIndex;
    }

    final flashcard = flashcards[_order[_currentIndex]];
    final progress = (_studiedIndexes.length / flashcards.length)
        .clamp(0, 1)
        .toDouble();
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
                    Chip(
                      avatar: const Icon(Icons.sell_outlined, size: 16),
                      label: Text(flashcard.category),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Card ${_currentIndex + 1} of ${flashcards.length}',
                        style: textTheme.labelLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(999),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
                const SizedBox(height: 10),
                Text(
                  '${_studiedIndexes.length} studied • ${_correctIndexes.length} correct',
                  textAlign: TextAlign.center,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 360),
                  transitionBuilder: (child, animation) {
                    final rotate = Tween<double>(
                      begin: math.pi / 2,
                      end: 0,
                    ).animate(animation);

                    return AnimatedBuilder(
                      animation: rotate,
                      child: child,
                      builder: (context, child) {
                        return Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(rotate.value),
                          alignment: Alignment.center,
                          child: child,
                        );
                      },
                    );
                  },
                  child: _StudyCardFace(
                    key: ValueKey('${flashcard.id}-$_showAnswer'),
                    flashcard: flashcard,
                    showAnswer: _showAnswer,
                    onShowAnswer: () => setState(() => _showAnswer = true),
                  ),
                ),
                const SizedBox(height: 24),
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
                        onPressed: _showAnswer
                            ? () => _markCorrectAndAdvance(flashcards.length)
                            : null,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Correct'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () => _next(flashcards.length),
                  icon: Icon(
                    _currentIndex == flashcards.length - 1
                        ? Icons.celebration_outlined
                        : Icons.arrow_forward,
                  ),
                  label: Text(
                    _currentIndex == flashcards.length - 1
                        ? 'Finish Session'
                        : 'Next',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _ensureOrder(int length) {
    if (_order.length == length) {
      return;
    }

    _order = List<int>.generate(length, (index) => index);
    if (_shuffleMode) {
      _order = [..._order]..shuffle();
    }
  }

  void _toggleShuffle() {
    setState(() {
      _shuffleMode = !_shuffleMode;
      _order = List<int>.generate(_order.length, (index) => index);
      if (_shuffleMode) {
        _order = [..._order]..shuffle();
      }
      _currentIndex = 0;
      _showAnswer = false;
      _studiedIndexes.clear();
      _correctIndexes.clear();
      _completionShown = false;
    });
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

  Future<void> _markCorrectAndAdvance(int totalCards) async {
    _studiedIndexes.add(_order[_currentIndex]);
    _correctIndexes.add(_order[_currentIndex]);
    await _advanceOrComplete(totalCards);
  }

  Future<void> _next(int totalCards) async {
    _studiedIndexes.add(_order[_currentIndex]);
    await _advanceOrComplete(totalCards);
  }

  Future<void> _advanceOrComplete(int totalCards) async {
    if (_currentIndex >= totalCards - 1) {
      await _completeSession(totalCards);
      return;
    }

    setState(() {
      _currentIndex++;
      _showAnswer = false;
    });
  }

  Future<void> _completeSession(int totalCards) async {
    if (_completionShown) {
      return;
    }

    _completionShown = true;
    await ref
        .read(studyProgressProvider.notifier)
        .recordSession(
          cardsStudied: _studiedIndexes.length,
          correctCount: _correctIndexes.length,
          totalCards: totalCards,
        );

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CompletionDialog(
        studied: _studiedIndexes.length,
        correct: _correctIndexes.length,
        total: totalCards,
        onReturnHome: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          if (mounted) {
            context.go(AppRoutes.home);
          }
        },
        onRestart: () {
          Navigator.of(context).pop();
          setState(() {
            _currentIndex = 0;
            _showAnswer = false;
            _completionShown = false;
            _studiedIndexes.clear();
            _correctIndexes.clear();
            if (_shuffleMode) {
              _order = [..._order]..shuffle();
            }
          });
        },
      ),
    );
  }
}

class _StudyCardFace extends StatelessWidget {
  const _StudyCardFace({
    required this.flashcard,
    required this.showAnswer,
    required this.onShowAnswer,
    super.key,
  });

  final FlashcardEntity flashcard;
  final bool showAnswer;
  final VoidCallback onShowAnswer;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 330),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: showAnswer
                  ? colorScheme.tertiaryContainer
                  : colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              showAnswer ? Icons.lightbulb_outline : Icons.help_outline,
              color: showAnswer
                  ? colorScheme.onTertiaryContainer
                  : colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            flashcard.question,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(height: 1.2),
          ),
          const SizedBox(height: 24),
          if (showAnswer)
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: Text(
                flashcard.answer,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            )
          else
            FilledButton.icon(
              onPressed: onShowAnswer,
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('Show Answer'),
            ),
        ],
      ),
    );
  }
}

class _CompletionDialog extends StatefulWidget {
  const _CompletionDialog({
    required this.studied,
    required this.correct,
    required this.total,
    required this.onReturnHome,
    required this.onRestart,
  });

  final int studied;
  final int correct;
  final int total;
  final VoidCallback onReturnHome;
  final VoidCallback onRestart;

  @override
  State<_CompletionDialog> createState() => _CompletionDialogState();
}

class _CompletionDialogState extends State<_CompletionDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percentage = widget.total == 0 ? 0 : widget.correct / widget.total;

    return AlertDialog(
      icon: SizedBox(
        width: 84,
        height: 84,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _BurstPainter(
                progress: _controller.value,
                color: colorScheme.tertiary,
              ),
              child: child,
            );
          },
          child: Icon(
            Icons.emoji_events_outlined,
            size: 44,
            color: colorScheme.tertiary,
          ),
        ),
      ),
      title: const Text('Study complete'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('You reviewed ${widget.studied} of ${widget.total} cards.'),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: percentage.clamp(0, 1).toDouble(),
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 8),
          Text('${widget.correct} correct this session'),
        ],
      ),
      actions: [
        TextButton(onPressed: widget.onRestart, child: const Text('Restart')),
        FilledButton.icon(
          onPressed: widget.onReturnHome,
          icon: const Icon(Icons.home_outlined),
          label: const Text('Return Home'),
        ),
      ],
    );
  }
}

class _BurstPainter extends CustomPainter {
  const _BurstPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = color.withValues(alpha: (1 - progress).clamp(0, 1))
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 12; i++) {
      final angle = (math.pi * 2 / 12) * i;
      final startRadius = 20 + progress * 8;
      final endRadius = 24 + progress * 24;
      final start =
          center + Offset(math.cos(angle), math.sin(angle)) * startRadius;
      final end = center + Offset(math.cos(angle), math.sin(angle)) * endRadius;
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
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
