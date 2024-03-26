import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final int uid;
  // final String photoUrl;
  final String name;
  final String cpf;

  const User(
      {required this.name,
      required this.uid,
      // required this.photoUrl,
      required this.email,
      required this.cpf});

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      name: snapshot["name"],
      uid: snapshot["uid"],
      email: snapshot["email"],
      // photoUrl: snapshot["photoUrl"],
      cpf: snapshot["cpf"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "uid": uid,
        "email": email,
        // "photoUrl": photoUrl,
        "cpf": cpf,
      };
}
