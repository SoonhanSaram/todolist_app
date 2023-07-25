import 'dart:convert';

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

  Future<List<dynamic>> getList() async {
    var res = await http.get(Uri.parse("http://192.168.0.5:3001/"));
    List<dynamic> data = jsonDecode(res.body);
    print(data);
    return data;
  }

  Future postList(title) async {
    var res = await http.post(
      Uri.parse("http://192.168.0.5:3001/"),
      body: {"title": title},
    );
  }

  Future UpdateState(number, state) async {
    await http.post(
      Uri.parse("http://192.168.0.5:3001/update"),
      body: {
        "todo_num": number.toString(),
        "state": (state == 0 ? 1 : 0).toString(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Todo todo = Todo();
    TodoProvider todoProvider = TodoProvider();
    TextEditingController textEditingController = TextEditingController();
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: textEditingController,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    postList(textEditingController.text);
                  },
                  child: const Text("할 일 추가"),
                )
              ],
            ),
          ),
          Expanded(child: todoList()),
        ],
      ),
    );
  }

  FutureBuilder<dynamic> todoList() {
    return FutureBuilder(
      future: getList(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snap.hasError) {
          return Text('Error: ${snap.error}');
        }
        final List<dynamic> data = snap.data;
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return data[index]['state'] == 0
                ? ListTile(
                    title: Row(
                      children: [
                        Text(
                          "${index + 1}",
                        ),
                        SizedBox(
                          height: 50,
                          child: Center(
                            child: Text(data[index]['title']),
                          ),
                        ),
                        const Icon(Icons.delete)
                      ],
                    ),
                    onTap: () {
                      UpdateState(
                        data[index]['todo_num'],
                        data[index]['state'],
                      );
                      setState(() {});
                    },
                  )
                : ListTile(
                    title: Container(
                      height: 50,
                      color: Colors.indigoAccent,
                      child: Center(
                        child: Text("${data[index]['title']} --- 완료"),
                      ),
                    ),
                    onTap: () {
                      UpdateState(
                        data[index]['todo_num'],
                        data[index]['state'],
                      );
                      setState(() {});
                    },
                  );
          },
        );
      },
    );
  }
}
