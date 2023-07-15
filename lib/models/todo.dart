class Todo {
  Todo({
    this.number = 1,
    this.sdate = "",
    this.udate = "",
    this.edate = "",
    this.stime = "",
    this.utime = "",
    this.etime = "",
    this.cdate = "",
    this.ctime = "",
    this.title = "",
    this.tag = "",
    this.detail = "",
    this.state = 0,
  });

  int number;
  String sdate;
  String udate;
  String edate;
  String stime;
  String utime;
  String etime;
  String cdate;
  String ctime;
  String title;
  String tag;
  String detail;
  int state;

  Map<String, dynamic> toMap() {
    return {
      "sdate": sdate,
      "udate": udate,
      "edate": edate,
      "stime": stime,
      "utime": utime,
      "etime": etime,
      "cdate": cdate,
      "ctime": ctime,
      "title": title,
      "tag": tag,
      "detail": detail,
      "state": state,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      number: map["number"] ?? 1, // null인 경우 기본값 1 할당
      sdate: map["sdate"] ?? "",
      udate: map["udate"] ?? "",
      edate: map["edate"] ?? "",
      stime: map["stime"] ?? "",
      utime: map["utime"] ?? "",
      etime: map["etime"] ?? "",
      cdate: map["cdate"] ?? "",
      ctime: map["ctime"] ?? "",
      title: map["title"] ?? "",
      tag: map["tag"] ?? "",
      detail: map["detail"] ?? "",
      state: map["state"] ?? 0,
    );
  }
}
