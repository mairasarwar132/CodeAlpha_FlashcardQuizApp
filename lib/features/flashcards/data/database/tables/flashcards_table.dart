import 'package:drift/drift.dart';

@DataClassName('FlashcardRecord')
class FlashcardsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get question => text()();

  TextColumn get answer => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
