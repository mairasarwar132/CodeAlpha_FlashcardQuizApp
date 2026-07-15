import 'dart:async';

import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/entities/study_progress_entity.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/providers/flashcard_data_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final studyProgressProvider =
    AsyncNotifierProvider<StudyProgressNotifier, List<StudyProgressEntity>>(
      StudyProgressNotifier.new,
    );

class StudyProgressNotifier extends AsyncNotifier<List<StudyProgressEntity>> {
  @override
  FutureOr<List<StudyProgressEntity>> build() {
    return _loadProgress();
  }

  Future<void> recordSession({
    required int cardsStudied,
    required int correctCount,
    required int totalCards,
  }) async {
    final database = ref.read(appDatabaseProvider);
    final studiedAt = DateTime.now().millisecondsSinceEpoch;

    state = await AsyncValue.guard(() async {
      await database.customStatement(
        '''
        INSERT INTO study_progress (
          studied_at,
          cards_studied,
          correct_count,
          total_cards
        ) VALUES (?, ?, ?, ?)
        ''',
        [studiedAt, cardsStudied, correctCount, totalCards],
      );
      return _loadProgress();
    });
  }

  Future<List<StudyProgressEntity>> _loadProgress() async {
    final database = ref.read(appDatabaseProvider);
    final rows = await database.customSelect('''
      SELECT id, studied_at, cards_studied, correct_count, total_cards
      FROM study_progress
      ORDER BY studied_at DESC
      ''').get();

    return rows
        .map((row) {
          return StudyProgressEntity(
            id: row.read<int>('id'),
            studiedAt: DateTime.fromMillisecondsSinceEpoch(
              row.read<int>('studied_at'),
            ),
            cardsStudied: row.read<int>('cards_studied'),
            correctCount: row.read<int>('correct_count'),
            totalCards: row.read<int>('total_cards'),
          );
        })
        .toList(growable: false);
  }
}

final studyStatsProvider = Provider<StudyStats>((ref) {
  final progress = ref.watch(studyProgressProvider).asData?.value ?? const [];

  return StudyStats.fromProgress(progress);
});

class StudyStats {
  const StudyStats({
    required this.cardsStudiedToday,
    required this.totalReviews,
    required this.studySessions,
    required this.completionPercentage,
    this.lastStudyTime,
  });

  final int cardsStudiedToday;
  final int totalReviews;
  final int studySessions;
  final double completionPercentage;
  final DateTime? lastStudyTime;

  factory StudyStats.fromProgress(List<StudyProgressEntity> progress) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var cardsStudiedToday = 0;
    var totalReviews = 0;
    var correct = 0;
    var totalCards = 0;

    for (final item in progress) {
      totalReviews += item.cardsStudied;
      correct += item.correctCount;
      totalCards += item.totalCards;

      if (!item.studiedAt.isBefore(today)) {
        cardsStudiedToday += item.cardsStudied;
      }
    }

    return StudyStats(
      cardsStudiedToday: cardsStudiedToday,
      totalReviews: totalReviews,
      studySessions: progress.length,
      completionPercentage: totalCards == 0 ? 0 : correct / totalCards,
      lastStudyTime: progress.isEmpty ? null : progress.first.studiedAt,
    );
  }
}
