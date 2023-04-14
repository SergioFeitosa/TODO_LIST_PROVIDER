import 'package:sqflite/sqflite.dart';
import 'package:todo_list_provider/app/core/database/migrations/migration.dart';

class MigrationV3 implements Migration {
  @override
  void create(Batch batch) {
    batch.execute('''
      create table teste3(
        id Integer primary key autoincrement,
        descricao varchar(500) not null,
        userId varchar(500) not null,
        data_hora datetime,
        finalizado integer
      )
    ''');
  }

  @override
  void upgrade(Batch batch) {
    batch.execute('''
    ''');
  }
}
