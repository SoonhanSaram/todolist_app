import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:todolist_app/comps/progress_bar.dart';

class ExpansionTiles extends StatelessWidget {
  const ExpansionTiles({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "todolist_App",
      theme: ThemeData.dark(),
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
  final url = Uri.parse(dotenv.env['LOCAL_URL'].toString());
  String option = "기본";
  bool showDetail = false;
  List<Widget> textFields = [];
  List<TextEditingController> detailControllers = [];
  TextEditingController todoController = TextEditingController();
  List<ProgressBar> progressBars = [];
  final DateTime systime = DateTime.now();
  late final User user;
  String? nickname;

  @override
  initState() {
    void check_user_info() async {
      try {
        User user = await UserApi.instance.me();
        nickname = user.kakaoAccount?.profile?.nickname;
        print('사용자 정보 요청 성공' '\n회원번호 : ${user.id}' '\n닉네임 : ${user.kakaoAccount?.profile?.nickname}');
      } catch (e) {
        print('사용자 정보 요청 실패 $e');
      }
    }

    check_user_info();
  }

  Future<List<dynamic>> getList() async {
    final newUrl = url.replace(
      queryParameters: {
        'nickname': nickname,
      },
    );
    var res = await http.get(newUrl);
    List<dynamic> data = jsonDecode(res.body);
    _buildProgressBars(data);
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
        body: jsonEncode({
          "title": title,
          "nickname": nickname,
        }),
      );
    } else {
      await http.post(
        url,
        headers: {
          "type": type,
        },
        body: {
          "title": title,
          "nickname": nickname,
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
        "nicknmae": nickname,
        "state": (state == 0 ? 1 : 0).toString(),
      },
    );
  }

  Future deleteTodo(number) async {
    await http.post(
      url.replace(path: '${url.path}delete'),
      body: {
        "todo_num": number.toString(),
        "nickname": nickname,
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: 20,
              ),
              const Text(
                "Todo Option   : ",
                style: TextStyle(fontSize: 16),
              ),
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
              const Text('한 개'),
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
              const Text('여러개'),
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
                    decoration: const InputDecoration(
                      labelText: "할 일을 입력해주세요",
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    controller: textEditingController,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
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
                child: const Icon(Icons.add_box_outlined, color: Colors.black),
              ),
              const SizedBox(
                width: 20,
              )
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
            // int completedCount = details.where((item) => item['state'] == 1).length;
            // double ratio = details.isEmpty ? 0 : completedCount / details.length;
            return data[index]['state'] == 0 && data[index]['details'].isEmpty
                ? ListTile(
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
                        const Expanded(
                          child: SizedBox(),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(30, 40),
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
                        const SizedBox(
                          width: 20,
                        ),
                        CustomPaint(
                          painter: progressBars[index],
                        ),
                      ],
                    ),
                    onTap: () {
                      updateState(data[index]['todo_num'], data[index]['state'], "todos");
                      setState(() {});
                    },
                  )
                : data[index]['state'] == 0 && data[index]['details'].isNotEmpty
                    ? ExpansionTile(
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
                            const Expanded(
                              child: SizedBox(),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(30, 40),
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
                            const SizedBox(
                              width: 20,
                            ),
                            CustomPaint(
                              painter: progressBars[index],
                            ),
                          ],
                        ),
                        children: [
                          ListView.builder(
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
                                    color: isCompleted ? Colors.grey : Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    : ListTile(
                        title: Container(
                          height: 50,
                          color: Colors.black,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Text("${data[index]['title']}  "), const Icon(Icons.check_sharp)],
                            ),
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

  void _buildProgressBars(List<dynamic> data) {
    progressBars.clear();
    for (int i = 0; i < data.length; i++) {
      if (data[i]['details'].isEmpty) {
        progressBars.add(ProgressBar(context: context, totalSlices: 1, drawSlices: 0));
      } else {
        int completedCount = data[i]['details'].where((item) => item['state'] == 1).length;
        int totalSlices = data[i]['details'].length;
        progressBars.add(
          ProgressBar(
            context: context,
            totalSlices: totalSlices,
            drawSlices: completedCount,
          ),
        );
      }
    }
    print(progressBars);
  }
}
