import 'package:codealpha_flashcard_quiz_app/features/flashcards/data/database/app_database.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/data/datasources/flashcard_local_data_source.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/data/repositories/drift_flashcard_repository.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/repositories/flashcard_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();

  ref.onDispose(database.close);

  return database;
});

final flashcardRepositoryProvider = Provider<FlashcardRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  final localDataSource = FlashcardLocalDataSource(database);

  return DriftFlashcardRepository(localDataSource);
});
