import 'package:drift/drift.dart';

@DataClassName('FlashcardRecord')
class FlashcardsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get question => text()();

  TextColumn get answer => text()();

  TextColumn get category => text().withDefault(const Constant('General'))();

  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
