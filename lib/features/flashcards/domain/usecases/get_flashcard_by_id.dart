import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/entities/flashcard_entity.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/repositories/flashcard_repository.dart';

class GetFlashcardById {
  const GetFlashcardById(this._repository);

  final FlashcardRepository _repository;

  Future<FlashcardEntity?> call(int id) {
    return _repository.getFlashcard(id);
  }
}
