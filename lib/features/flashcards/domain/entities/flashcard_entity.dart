import 'package:equatable/equatable.dart';

class FlashcardEntity extends Equatable {
  const FlashcardEntity({
    this.id,
    required this.question,
    required this.answer,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String question;
  final String answer;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, question, answer, createdAt, updatedAt];
}
