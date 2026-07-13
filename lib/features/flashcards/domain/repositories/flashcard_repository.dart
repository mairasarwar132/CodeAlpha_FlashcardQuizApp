import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/entities/flashcard_entity.dart';

abstract interface class FlashcardRepository {
  Future<List<FlashcardEntity>> getAllFlashcards();

  Future<FlashcardEntity?> getFlashcard(int id);

  Future<int> insertFlashcard(FlashcardEntity flashcard);

  Future<bool> updateFlashcard(FlashcardEntity flashcard);

  Future<int> deleteFlashcard(int id);
}
