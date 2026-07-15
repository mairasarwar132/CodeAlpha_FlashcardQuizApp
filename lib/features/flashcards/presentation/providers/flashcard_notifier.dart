import 'dart:async';

import 'package:codealpha_flashcard_quiz_app/features/flashcards/domain/entities/flashcard_entity.dart';
import 'package:codealpha_flashcard_quiz_app/features/flashcards/presentation/providers/flashcard_data_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final flashcardNotifierProvider =
    AsyncNotifierProvider<FlashcardNotifier, List<FlashcardEntity>>(
      FlashcardNotifier.new,
    );

class FlashcardNotifier extends AsyncNotifier<List<FlashcardEntity>> {
  @override
  FutureOr<List<FlashcardEntity>> build() {
    return _loadFlashcards();
  }

  Future<void> loadFlashcards() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadFlashcards);
  }

  Future<void> refresh() {
    return loadFlashcards();
  }

  Future<FlashcardEntity?> getFlashcard(int id) async {
    try {
      return ref.read(getFlashcardByIdProvider).call(id);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return null;
    }
  }

  Future<void> addFlashcard({
    required String question,
    required String answer,
    required String category,
    required bool isFavorite,
  }) {
    return _mutateAndRefresh(
      () => ref
          .read(addFlashcardProvider)
          .call(
            question: question,
            answer: answer,
            category: category,
            isFavorite: isFavorite,
          ),
    );
  }

  Future<void> updateFlashcard(FlashcardEntity flashcard) {
    return _mutateAndRefresh(
      () => ref.read(updateFlashcardProvider).call(flashcard),
    );
  }

  Future<void> deleteFlashcard(int id) {
    return _mutateAndRefresh(() => ref.read(deleteFlashcardProvider).call(id));
  }

  Future<void> toggleFavorite(FlashcardEntity flashcard) {
    return updateFlashcard(
      FlashcardEntity(
        id: flashcard.id,
        question: flashcard.question,
        answer: flashcard.answer,
        category: flashcard.category,
        isFavorite: !flashcard.isFavorite,
        createdAt: flashcard.createdAt,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<List<FlashcardEntity>> _loadFlashcards() {
    return ref.read(getAllFlashcardsProvider).call();
  }

  Future<void> _mutateAndRefresh(Future<Object?> Function() mutation) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      await mutation();
      return _loadFlashcards();
    });

    state = result;
  }
}
