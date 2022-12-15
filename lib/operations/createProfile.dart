class CreateProfile {
  String uid;

  final String email;
  final String image;

  CreateProfile({
    this.uid = '',
    required this.email,
    required this.image,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'image': image,
      };

  static CreateProfile fromJson(Map<String, dynamic> json) => CreateProfile(
        uid: json['uid'],
        email: json['email'],
        image: json['image'],
      );
}
