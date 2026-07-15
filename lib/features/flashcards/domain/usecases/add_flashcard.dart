import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/entities/flashcard_entity.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/repositories/flashcard_repository.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/usecases/flashcard_validator.dart';

class AddFlashcard {
  const AddFlashcard(
    this._repository, {
    FlashcardValidator validator = const FlashcardValidator(),
  }) : _validator = validator;

  final FlashcardRepository _repository;
  final FlashcardValidator _validator;

  Future<int> call({
    required String question,
    required String answer,
    String category = 'General',
    bool isFavorite = false,
  }) {
    final now = DateTime.now();
    final flashcard = FlashcardEntity(
      question: _validator.question(question),
      answer: _validator.answer(answer),
      category: _validator.category(category),
      isFavorite: isFavorite,
      createdAt: now,
      updatedAt: now,
    );

    return _repository.insertFlashcard(flashcard);
  }
}
