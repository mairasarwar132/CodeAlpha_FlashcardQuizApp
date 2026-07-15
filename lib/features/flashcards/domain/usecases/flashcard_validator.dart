import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/usecases/flashcard_validation_exception.dart';

class FlashcardValidator {
  const FlashcardValidator();

  String question(String value) {
    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      throw const FlashcardValidationException('Question is required.');
    }

    return trimmedValue;
  }

  String answer(String value) {
    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      throw const FlashcardValidationException('Answer is required.');
    }

    return trimmedValue;
  }

  String category(String value) {
    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return 'General';
    }

    return trimmedValue;
  }
}
