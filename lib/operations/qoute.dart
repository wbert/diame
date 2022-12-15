class Qoute {
  final String content;
  final String author;

  Qoute({
    required this.content,
    required this.author,
  });

  factory Qoute.fromJson(Map<String, dynamic> json) {
    return Qoute(
      content: json["content"],
      author: json["author"],
    );
  }
}
