import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/repositories/flashcard_repository.dart';

class DeleteFlashcard {
  const DeleteFlashcard(this._repository);

  final FlashcardRepository _repository;

  Future<int> call(int id) {
    return _repository.deleteFlashcard(id);
  }
}
