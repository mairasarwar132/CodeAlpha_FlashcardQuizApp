import 'package:codealpha_flashcard_quiz_app/features/flashcards/data/database/app_database.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/data/datasources/flashcard_local_data_source.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/data/repositories/drift_flashcard_repository.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/repositories/flashcard_repository.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/usecases/add_flashcard.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/usecases/delete_flashcard.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/usecases/get_all_flashcards.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/usecases/get_flashcard_by_id.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/usecases/update_flashcard.dart';
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

final getAllFlashcardsProvider = Provider<GetAllFlashcards>((ref) {
  return GetAllFlashcards(ref.watch(flashcardRepositoryProvider));
});

final getFlashcardByIdProvider = Provider<GetFlashcardById>((ref) {
  return GetFlashcardById(ref.watch(flashcardRepositoryProvider));
});

final addFlashcardProvider = Provider<AddFlashcard>((ref) {
  return AddFlashcard(ref.watch(flashcardRepositoryProvider));
});

final updateFlashcardProvider = Provider<UpdateFlashcard>((ref) {
  return UpdateFlashcard(ref.watch(flashcardRepositoryProvider));
});

final deleteFlashcardProvider = Provider<DeleteFlashcard>((ref) {
  return DeleteFlashcard(ref.watch(flashcardRepositoryProvider));
});
