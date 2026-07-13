class FlashcardValidationException implements Exception {
  const FlashcardValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
