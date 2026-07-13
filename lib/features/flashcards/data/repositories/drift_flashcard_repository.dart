import 'package:codealpha_flashcard_quiz_app/features/flashcards/data/datasources/flashcard_local_data_source.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/data/models/flashcard_model.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/entities/flashcard_entity.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/repositories/flashcard_repository.dart';

class DriftFlashcardRepository implements FlashcardRepository {
  const DriftFlashcardRepository(this._localDataSource);

  final FlashcardLocalDataSource _localDataSource;

  @override
  Future<List<FlashcardEntity>> getAllFlashcards() async {
    final flashcards = await _localDataSource.getAllFlashcards();

    return flashcards.map((flashcard) => flashcard.toEntity()).toList();
  }

  @override
  Future<FlashcardEntity?> getFlashcard(int id) async {
    final flashcard = await _localDataSource.getFlashcard(id);

    return flashcard?.toEntity();
  }

  @override
  Future<int> insertFlashcard(FlashcardEntity flashcard) {
    return _localDataSource.insertFlashcard(
      FlashcardModel.fromEntity(flashcard),
    );
  }

  @override
  Future<bool> updateFlashcard(FlashcardEntity flashcard) {
    return _localDataSource.updateFlashcard(
      FlashcardModel.fromEntity(flashcard),
    );
  }

  @override
  Future<int> deleteFlashcard(int id) {
    return _localDataSource.deleteFlashcard(id);
  }
}
