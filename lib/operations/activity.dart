class Activity {
  final String activity;

  const Activity({
    required this.activity,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      activity: json['activity'],
    );
  }
}
