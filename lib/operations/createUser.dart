class User {
  String id;
  String uid;
  final String monthDate;
  final String year;
  final String title;
  final String body;

  User({
    this.id = '',
    this.uid = '',
    required this.monthDate,
    required this.year,
    required this.title,
    required this.body,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'uid': uid,
        'monthDate': monthDate,
        'year': year,
        'title': title,
        'body': body,
      };

  static User fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        uid: json['uid'],
        monthDate: json['monthDate'],
        year: json['year'],
        title: json['title'],
        body: json['body'],
      );
}
