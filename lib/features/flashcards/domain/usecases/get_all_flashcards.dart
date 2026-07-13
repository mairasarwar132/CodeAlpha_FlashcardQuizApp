import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/entities/flashcard_entity.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/repositories/flashcard_repository.dart';

class GetAllFlashcards {
  const GetAllFlashcards(this._repository);

  final FlashcardRepository _repository;

  Future<List<FlashcardEntity>> call() {
    return _repository.getAllFlashcards();
  }
}
