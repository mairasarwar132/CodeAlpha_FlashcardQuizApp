import 'package:equatable/equatable.dart';

class StudyProgressEntity extends Equatable {
  const StudyProgressEntity({
    this.id,
    required this.studiedAt,
    required this.cardsStudied,
    required this.correctCount,
    required this.totalCards,
  });

  final int? id;
  final DateTime studiedAt;
  final int cardsStudied;
  final int correctCount;
  final int totalCards;

  double get completion {
    if (totalCards == 0) {
      return 0;
    }

    return (correctCount / totalCards).clamp(0, 1);
  }

  @override
  List<Object?> get props => [
    id,
    studiedAt,
    cardsStudied,
    correctCount,
    totalCards,
  ];
}
