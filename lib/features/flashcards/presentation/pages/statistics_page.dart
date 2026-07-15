import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/providers/flashcard_notifier.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/providers/study_progress_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashcards = ref.watch(flashcardNotifierProvider).asData?.value ?? [];
    final stats = ref.watch(studyStatsProvider);
    final favoriteCards = flashcards.where((card) => card.isFavorite).length;
    final categories = flashcards.map((card) => card.category).toSet().length;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          _ProgressHero(completion: stats.completionPercentage),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width > 680 ? 3 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _MetricCard(
                icon: Icons.style_outlined,
                label: 'Total cards',
                value: '${flashcards.length}',
              ),
              _MetricCard(
                icon: Icons.star_border_rounded,
                label: 'Favorites',
                value: '$favoriteCards',
              ),
              _MetricCard(
                icon: Icons.category_outlined,
                label: 'Categories',
                value: '$categories',
              ),
              _MetricCard(
                icon: Icons.today_outlined,
                label: 'Studied today',
                value: '${stats.cardsStudiedToday}',
              ),
              _MetricCard(
                icon: Icons.repeat_rounded,
                label: 'Study sessions',
                value: '${stats.studySessions}',
              ),
              _MetricCard(
                icon: Icons.fact_check_outlined,
                label: 'Total reviews',
                value: '${stats.totalReviews}',
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ReviewChart(
            cards: flashcards.length,
            reviews: stats.totalReviews,
            favorites: favoriteCards,
          ),
          const SizedBox(height: 18),
          _LastStudyCard(lastStudyTime: stats.lastStudyTime),
        ],
      ),
    );
  }
}

class _ProgressHero extends StatelessWidget {
  const _ProgressHero({required this.completion});

  final double completion;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 92,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: completion.clamp(0, 1),
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  backgroundColor: colorScheme.surface.withValues(alpha: 0.45),
                ),
                Center(
                  child: Text(
                    '${(completion * 100).round()}%',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Completion progress',
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Based on correct answers from completed study sessions.',
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary),
            const Spacer(),
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewChart extends StatelessWidget {
  const _ReviewChart({
    required this.cards,
    required this.reviews,
    required this.favorites,
  });

  final int cards;
  final int reviews;
  final int favorites;

  @override
  Widget build(BuildContext context) {
    final maxValue = [
      cards,
      reviews,
      favorites,
      1,
    ].reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learning activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 18),
            _ChartBar(label: 'Cards', value: cards, maxValue: maxValue),
            const SizedBox(height: 12),
            _ChartBar(label: 'Reviews', value: reviews, maxValue: maxValue),
            const SizedBox(height: 12),
            _ChartBar(label: 'Favorites', value: favorites, maxValue: maxValue),
          ],
        ),
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  const _ChartBar({
    required this.label,
    required this.value,
    required this.maxValue,
  });

  final String label;
  final int value;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(width: 76, child: Text(label)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: maxValue == 0 ? 0 : value / maxValue,
              minHeight: 12,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(width: 36, child: Text('$value', textAlign: TextAlign.end)),
      ],
    );
  }
}

class _LastStudyCard extends StatelessWidget {
  const _LastStudyCard({required this.lastStudyTime});

  final DateTime? lastStudyTime;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final value = lastStudyTime == null
        ? 'No study sessions yet'
        : '${lastStudyTime!.month}/${lastStudyTime!.day}/${lastStudyTime!.year} '
              '${lastStudyTime!.hour.toString().padLeft(2, '0')}:'
              '${lastStudyTime!.minute.toString().padLeft(2, '0')}';

    return Card(
      child: ListTile(
        leading: Icon(Icons.schedule_outlined, color: colorScheme.primary),
        title: const Text('Last study time'),
        subtitle: Text(value),
      ),
    );
  }
}
