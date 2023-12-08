import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tcc_app/models/complaint_model.dart';
import 'package:tcc_app/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(
      String description,
      List<dynamic> files,
      String uid,
      GeoPoint? local,
      DateTime dateOfOccurrence,
      DateTime hourOfOccurrence) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      List<String> photoUrls = [];
      var collection = _firestore.collection('users');
      var docSnapshot = await collection.doc(uid).get();
      String name = '';
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();
        name = data?['username']; // <-- The value you want to retrieve.
        // Call setState if needed.
      }
      for (dynamic file in files) {
        String photoUrl = await StorageMethods()
            .uploadImageToStorage('complaints', file, true);
        photoUrls.add(photoUrl);
      }
      String complaintId = const Uuid().v1(); // creates unique id based on time
      print('locale: $local');
      Complaint complaint = Complaint(
          description: description,
          uid: uid,
          name: name,
          likes: [],
          deslikes: [],
          complaintId: complaintId,
          datePublished: DateTime.now(),
          imagesUrl: photoUrls,
          // resolved: false as Bool,
          // anonymous: false as Bool,
          local: local,
          dateOfOccurrence: dateOfOccurrence,
          hourOfOccurrence: hourOfOccurrence);
      print('COMPLAINT JSON');
      print(complaint.toJson());
      _firestore
          .collection('complaints')
          .doc(complaintId)
          .set(complaint.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<List<Complaint>> getComplaints() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('complaints').get();

      List<Complaint> complaints = [];
      // print('BEFORE FOR');
      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        // Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        // print('BEFORE FROMSNAP');
        // Certifique-se de que o seu modelo Complaint tenha um construtor apropriado
        // para converter os dados do Firestore para o objeto Complaint.
        Complaint complaint = Complaint.fromSnap(document);

        // print('snap: $complaint');
        complaints.add(complaint);
      }
      // print('AFTER FOR');

      return complaints;
    } catch (error) {
      print("Erro ao obter denúncias: $error");
      throw error.toString();
    }
  }
}
