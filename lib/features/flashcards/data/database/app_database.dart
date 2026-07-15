import 'package:codealpha_flashcard_quiz_app/features/flashcards/data/database/tables/flashcards_table.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [FlashcardsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.addColumn(flashcardsTable, flashcardsTable.category);
          await migrator.addColumn(flashcardsTable, flashcardsTable.isFavorite);
          await customStatement('''
            CREATE TABLE IF NOT EXISTS study_progress (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              studied_at INTEGER NOT NULL,
              cards_studied INTEGER NOT NULL,
              correct_count INTEGER NOT NULL,
              total_cards INTEGER NOT NULL
            )
          ''');
        }
      },
      beforeOpen: (details) async {
        await customStatement('''
          CREATE TABLE IF NOT EXISTS study_progress (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            studied_at INTEGER NOT NULL,
            cards_studied INTEGER NOT NULL,
            correct_count INTEGER NOT NULL,
            total_cards INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'codealpha_flashcards');
  }
}
