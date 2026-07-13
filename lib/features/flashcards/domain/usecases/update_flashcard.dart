import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/entities/flashcard_entity.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/repositories/flashcard_repository.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/usecases/flashcard_validation_exception.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/usecases/flashcard_validator.dart';

class UpdateFlashcard {
  const UpdateFlashcard(
    this._repository, {
    FlashcardValidator validator = const FlashcardValidator(),
  }) : _validator = validator;

  final FlashcardRepository _repository;
  final FlashcardValidator _validator;

  Future<bool> call(FlashcardEntity flashcard) {
    final id = flashcard.id;

    if (id == null) {
      throw const FlashcardValidationException('Flashcard id is required.');
    }

    final updatedFlashcard = FlashcardEntity(
      id: id,
      question: _validator.question(flashcard.question),
      answer: _validator.answer(flashcard.answer),
      createdAt: flashcard.createdAt,
      updatedAt: DateTime.now(),
    );

    return _repository.updateFlashcard(updatedFlashcard);
  }
}
