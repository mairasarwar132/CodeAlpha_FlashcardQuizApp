import 'package:codealpha_flashcard_quiz_app/features/flashcards/data/database/app_database.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/data/models/flashcard_model.dart';

class FlashcardLocalDataSource {
  const FlashcardLocalDataSource(this._database);

  final AppDatabase _database;

  Future<List<FlashcardModel>> getAllFlashcards() async {
    final records = await _database.select(_database.flashcardsTable).get();

    return records.map(FlashcardModel.fromRecord).toList(growable: false);
  }

  Future<FlashcardModel?> getFlashcard(int id) async {
    final query = _database.select(_database.flashcardsTable)
      ..where((table) => table.id.equals(id));
    final record = await query.getSingleOrNull();

    return record == null ? null : FlashcardModel.fromRecord(record);
  }

  Future<int> insertFlashcard(FlashcardModel flashcard) {
    return _database
        .into(_database.flashcardsTable)
        .insert(flashcard.toCompanion());
  }

  Future<bool> updateFlashcard(FlashcardModel flashcard) {
    return _database
        .update(_database.flashcardsTable)
        .replace(flashcard.toCompanion(includeId: true));
  }

  Future<int> deleteFlashcard(int id) {
    final query = _database.delete(_database.flashcardsTable)
      ..where((table) => table.id.equals(id));

    return query.go();
  }
}
