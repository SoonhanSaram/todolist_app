import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todolist_app/models/todo.dart';
import 'package:todolist_app/models/todo_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  TodoProvider todoProvider = TodoProvider();
  await todoProvider.initDB();
  runApp(const Todolist());
}

class Todolist extends StatelessWidget {
  const Todolist({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "todolist_App",
      theme: ThemeData(primaryColor: Colors.black),
      home: const ListPage(),
    );
  }
}

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  String option = "기본";
  TextEditingController todoController = TextEditingController();
  final DateTime systime = DateTime.now();

  Future fetch() async {
    var res = await http.get(Uri.parse("http://192.168.0.5:3001/"));
    return res.body;
  }

  @override
  Widget build(BuildContext context) {
    Todo todo = Todo();
    TodoProvider todoProvider = TodoProvider();

    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: fetch(),
          builder: (context, snap) {
            if (!snap.hasData) return const CircularProgressIndicator();
            return Text(snap.data);
          },
        ),
      ),
    );
  }
}
