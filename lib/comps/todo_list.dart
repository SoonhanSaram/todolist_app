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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${index + 1}. "),
                      Expanded(
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
                    itemCount: data[index]['details'].length,
                    itemBuilder: (context, subIndex) {
                      return ListTile(
                        onTap: () {
                          updateState(
                            data[index]['details'][subIndex]['details_num'],
                            data[index]['details'][subIndex]['state'],
                            "details",
                          );
                        },
                        title: Text(
                          "${subIndex + 1} : ${data[index]['details'][subIndex]['title']}",
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
                    color: Colors.indigoAccent,
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
