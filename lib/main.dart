import 'package:flutter/material.dart';
import 'package:todolist_app/models/todo_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  TodoProvider todoProvider = TodoProvider();
  await todoProvider.initDB();
  runApp(const Todolist());
}

class Todolist extends StatelessWidget {
  const Todolist({super.key});

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
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  String option = "기본";
  TextEditingController? todoController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height * 0.3,
        child: Row(
          children: [
            Radio(
              value: "기본",
              groupValue: option,
              onChanged: (value) {
                setState(
                  () {
                    option = value!;
                  },
                );
              },
            ),
            Radio(
              value: "상세",
              groupValue: option,
              onChanged: (value) {
                setState(
                  () {
                    option = value!;
                  },
                );
              },
            ),
            Expanded(
              child: TextField(
                controller: todoController,
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text("추가하기"),
            )
          ],
        ),
      ),
    );
  }
}
