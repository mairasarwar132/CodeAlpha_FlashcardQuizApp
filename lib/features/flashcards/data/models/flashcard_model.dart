import 'package:codealpha_flashcard_quiz_app/features/flashcards/data/database/app_database.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/entities/flashcard_entity.dart';
import 'package:drift/drift.dart';

class FlashcardModel extends FlashcardEntity {
  const FlashcardModel({
    super.id,
    required super.question,
    required super.answer,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FlashcardModel.fromEntity(FlashcardEntity entity) {
    return FlashcardModel(
      id: entity.id,
      question: entity.question,
      answer: entity.answer,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory FlashcardModel.fromRecord(FlashcardRecord record) {
    return FlashcardModel(
      id: record.id,
      question: record.question,
      answer: record.answer,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }

  FlashcardEntity toEntity() {
    return FlashcardEntity(
      id: id,
      question: question,
      answer: answer,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  FlashcardsTableCompanion toCompanion({bool includeId = false}) {
    return FlashcardsTableCompanion(
      id: includeId && id != null ? Value(id!) : const Value.absent(),
      question: Value(question),
      answer: Value(answer),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }
}
