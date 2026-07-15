import 'package:equatable/equatable.dart';

class FlashcardEntity extends Equatable {
  const FlashcardEntity({
    this.id,
    required this.question,
    required this.answer,
    this.category = 'General',
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String question;
  final String answer;
  final String category;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    question,
    answer,
    category,
    isFavorite,
    createdAt,
    updatedAt,
  ];
}
