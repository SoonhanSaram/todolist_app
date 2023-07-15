import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todolist_app/models/todo.dart';

class TodoProvider {
  late Database _database;
  Todo todo = Todo();
  Future<Database> get database async {
    _database = await initDB();
    return _database;
  }

  Future<void> createTodo(Todo todo) async {
    final db = await database;
    await db.insert('Todo', todo.toMap());
  }

  Future<List<Todo>> getTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Todo');
    return List.generate(maps.length, (index) {
      return Todo.fromMap(maps[index]);
    });
  }

  Future<void> updateTodo(Todo todo) async {
    final db = await database;
    await db.update(
      'Todo',
      todo.toMap(),
      where: 'number = ?',
      whereArgs: [todo.number],
    );
  }

  Future<void> deleteTodo(int number) async {
    final db = await database;
    await db.delete(
      'Todo',
      where: 'number = ?',
      whereArgs: [number],
    );
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
