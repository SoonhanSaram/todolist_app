import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

// 기본적인 Listtile version

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
  final url = Uri.parse("http://192.168.0.5:3001/");
  String option = "기본";
  bool showDetail = false;
  List<Widget> textFields = [];
  List<TextEditingController> detailControllers = [];
  TextEditingController todoController = TextEditingController();

  final DateTime systime = DateTime.now();

  Future<List<dynamic>> getList() async {
    var res = await http.get(url);
    List<dynamic> data = jsonDecode(res.body);
    // print(data);
    return data;
  }

  Future postList(dynamic title, type) async {
    if (type != "false") {
      await http.post(
        url,
        headers: {
          "type": type,
          "Content-Type": "application/json",
        },
        body: jsonEncode({"title": title}),
      );
    } else {
      await http.post(
        url,
        headers: {
          "type": type,
        },
        body: {
          "title": title,
        },
      );
    }
  }

  Future updateState(number, state, database) async {
    await http.post(
      url.replace(path: "${url.path}update"),
      headers: {"dataBase": database},
      body: {
        "todo_num": number.toString(),
        "state": (state == 0 ? 1 : 0).toString(),
      },
    );
  }

  Future deleteTodo(number) async {
    await http.post(
      url.replace(path: '${url.path}delete'),
      body: {
        "todo_num": number.toString(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController textEditingController = TextEditingController();

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Radio(
                value: false,
                groupValue: showDetail,
                onChanged: (value) {
                  detailControllers.clear();
                  textFields.clear();
                  setState(() {
                    showDetail = false;
                  });
                },
              ),
              const Text('기본'),
              Radio(
                value: true,
                groupValue: showDetail,
                onChanged: (value) {
                  setState(() {
                    showDetail = true;
                    if (showDetail) {
                      textFields.add(_buildTextField(context));
                    } else {
                      textFields.clear();
                    }
                  });
                },
              ),
              const Text('상세'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: textEditingController,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (textEditingController.text.isEmpty) {
                    showToast();
                  } else {
                    if (detailControllers.isEmpty) {
                      postList(textEditingController.text, showDetail.toString());
                    } else if (detailControllers.isNotEmpty) {
                      List<String> temp = [];
                      temp.add(textEditingController.text);
                      temp.addAll(detailControllers.map((controller) => controller.text));
                      postList(temp, showDetail.toString());
                    }
                  }
                  showDetail = false;
                  detailControllers.clear();
                  textFields.clear();
                  setState(() {});
                },
                child: const Text("할 일 추가"),
              ),
            ],
          ),
          ...textFields,
          SizedBox(height: MediaQuery.of(context).size.height * 0.002),
          Expanded(
            flex: 4,
            child: todoList(),
          ),
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
        final List<dynamic> data = snap.data!;
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            List<dynamic> details = data[index]['details'];
            int completedCount = details.where((item) => item['state'] == 1).length;
            double ratio = details.isEmpty ? 0 : completedCount / details.length;
            return data[index]['state'] == 0
                ? ListTile(
                    tileColor: Colors.indigoAccent.withOpacity(ratio),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${index + 1}. "),
                        SizedBox(
                          height: 25,
                          child: Text(
                            data[index]['title'],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(40, 40),
                          ),
                          onPressed: () {
                            deleteTodo(
                              data[index]['todo_num'],
                            );
                            setState(() {});
                          },
                          child: const Icon(
                            Icons.delete,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    subtitle: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: details.length,
                      itemBuilder: (context, subIndex) {
                        bool isCompleted = details[subIndex]['state'] == 1;
                        return ListTile(
                          onTap: () {
                            updateState(
                              details[subIndex]['details_num'],
                              details[subIndex]['state'],
                              "details",
                            );
                            setState(() {});
                          },
                          title: Text(
                            "${subIndex + 1} : ${details[subIndex]['title']}",
                            style: TextStyle(
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              color: isCompleted ? Colors.grey : Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      updateState(
                        data[index]['todo_num'],
                        data[index]['state'],
                        "todos",
                      );
                      setState(() {});
                    },
                  )
                : ListTile(
                    title: Container(
                      height: 50,
                      color: Colors.white,
                      child: Center(
                        child: Text("${data[index]['title']} --- 완료"),
                      ),
                    ),
                    onTap: () {
                      updateState(data[index]['todo_num'], data[index]['state'], "todos");
                      setState(() {});
                    },
                  );
          },
        );
      },
    );
  }

  Widget _buildTextField(context) {
    TextEditingController controller = TextEditingController();
    detailControllers.add(controller);
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: controller,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: EdgeInsets.zero,
            minimumSize: const Size(40, 40),
          ),
          onPressed: () {
            setState(() {
              textFields.removeLast();
            });
          },
          child: const Icon(
            Icons.remove,
            color: Colors.black,
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.002,
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: EdgeInsets.zero,
            minimumSize: const Size(40, 40),
          ),
          onPressed: () {
            setState(() {
              textFields.add(_buildTextField(context));
            });
          },
          child: const Icon(
            Icons.add,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  void showToast() {
    Fluttertoast.showToast(
      msg: "내용을 입력해주세요",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }
}
