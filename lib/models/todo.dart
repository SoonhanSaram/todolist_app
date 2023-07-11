class Todo {
  Todo({
    required this.number,
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
      "number": number,
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
}
