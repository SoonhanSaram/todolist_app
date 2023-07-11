import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TodoProvider {
  late Database _database;

  Future<Database> get database async {
    _database = await initDB();
    return _database;
  }

  initDB() async {
    String path = join(await getDatabasesPath(), 'todo.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
          CREATE TABLE Todo(
          number INTEGET PRIMATY KEY AUTO_INCREMENT,
          sdate STRING,
          udate STRING,
          edate STRING,
          stime STRING,
          utime STRING,
          etime STRING,
          cdate STRING,
          ctime STRING,
          title STRING NOT NULL,
          tag STRING,
          detail INTEGER,
           state INTEGET,
          foreign key (detail) references TodoDetail (detailNum)
          );
        ''');
      await db.execute('''
          CREATE TABLE TodoDetail(
          detailNum INTEGET PRIMATY KEY AUTO_INCREMENT,
          state INTEGER,
          tnumber String
          );
        ''');
    });
  }
}
