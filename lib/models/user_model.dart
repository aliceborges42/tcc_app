class User {
  final String email;
  final int uid;
  // final String photoUrl;
  final String name;
  final String cpf;
  final String? avatar;

  const User(
      {required this.name,
      required this.uid,
      // required this.photoUrl,
      required this.email,
      required this.cpf,
      this.avatar});

  Map<String, dynamic> toJson() => {
        "name": name,
        "uid": uid,
        "email": email,
        // "photoUrl": photoUrl,
        "cpf": cpf,
        "avatar": avatar,
      };
}
