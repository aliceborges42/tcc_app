// import 'dart:async';
// import 'dart:ffi';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:tcc_app/models/complaint_model.dart';
// import 'package:tcc_app/resources/storage_methods.dart';
// import 'package:uuid/uuid.dart';

// class FireStoreMethods {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<String> uploadPost(
//     String description,
//     List<dynamic> files,
//     String uid,
//     GeoPoint? local,
//     DateTime dateOfOccurrence,
//     DateTime hourOfOccurrence,
//     String complaintType,
//     String typeSpecification,
//   ) async {
//     // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
//     String res = "Some error occurred";
//     try {
//       List<String> photoUrls = [];
//       var collection = _firestore.collection('users');
//       var docSnapshot = await collection.doc(uid).get();
//       String name = '';
//       if (docSnapshot.exists) {
//         Map<String, dynamic>? data = docSnapshot.data();
//         name = data?['username']; // <-- The value you want to retrieve.
//         // Call setState if needed.
//       }

//       for (dynamic file in files) {
//         try {
//           String photoUrl = await StorageMethods()
//               .uploadImageToStorage('complaints', file, true);
//           photoUrls.add(photoUrl);
//         } catch (storageError) {
//           // Lidar com erros de armazenamento aqui
//           print("Erro de armazenamento: $storageError");
//         }
//       }

//       String complaintId =
//           const Uuid().v1(); // cria um ID exclusivo com base no tempo
//       print('locale: $local');
//       Complaint complaint = Complaint(
//         description: description,
//         uid: uid,
//         name: name,
//         likes: [],
//         deslikes: [],
//         complaintId: complaintId,
//         datePublished: DateTime.now(),
//         imagesUrl: photoUrls,
//         local: local,
//         dateOfOccurrence: dateOfOccurrence,
//         hourOfOccurrence: hourOfOccurrence,
//         complaintType: complaintType,
//         typeSpecification: typeSpecification,
//       );
//       print('COMPLAINT JSON');
//       print(complaint.toJson());
//       _firestore
//           .collection('complaints')
//           .doc(complaintId)
//           .set(complaint.toJson());
//       res = "success";
//     } catch (err) {
//       // Lidar com erros gerais aqui
//       print("Erro ao processar denúncia: $err");
//       res = err.toString();
//     }
//     return res;
//   }

//   Future<List<Complaint>> getComplaints() async {
//     try {
//       QuerySnapshot querySnapshot =
//           await _firestore.collection('complaints').get();

//       List<Complaint> complaints = [];
//       // print('BEFORE FOR');
//       for (QueryDocumentSnapshot document in querySnapshot.docs) {
//         // Map<String, dynamic> data = document.data() as Map<String, dynamic>;
//         // print('BEFORE FROMSNAP');
//         // Certifique-se de que o seu modelo Complaint tenha um construtor apropriado
//         // para converter os dados do Firestore para o objeto Complaint.
//         Complaint complaint = Complaint.fromSnap(document);

//         // print('snap: $complaint');
//         complaints.add(complaint);
//       }
//       // print('AFTER FOR');

//       return complaints;
//     } catch (error) {
//       print("Erro ao obter denúncias: $error");
//       throw error.toString();
//     }
//   }

//   // Obter um Stream que emite uma lista de Complaints sempre que houver alterações no Firestore
//   Stream<List<Complaint>> getComplaintsStream() {
//     try {
//       // Configurar um StreamController para emitir as atualizações
//       StreamController<List<Complaint>> controller =
//           StreamController<List<Complaint>>();

//       // Obter a referência da coleção
//       CollectionReference complaintsCollection =
//           _firestore.collection('complaints');

//       // Configurar um ouvinte em tempo real para a coleção
//       StreamSubscription<QuerySnapshot> subscription =
//           complaintsCollection.snapshots().listen((querySnapshot) {
//         // Mapear os documentos para a lista de Complaints
//         List<Complaint> complaints = querySnapshot.docs
//             .map((document) => Complaint.fromSnap(document))
//             .toList();

//         // Adicionar a lista de Complaints ao StreamController
//         controller.add(complaints);
//       });

//       // Retornar o Stream
//       return controller.stream;
//     } catch (error) {
//       print("Erro ao obter stream de denúncias: $error");
//       throw error.toString();
//     }
//   }

//   Future<Complaint?> getComplaintById(String complaintId) async {
//     try {
//       DocumentSnapshot documentSnapshot =
//           await _firestore.collection('complaints').doc(complaintId).get();

//       if (documentSnapshot.exists) {
//         // Certifique-se de que o seu modelo Complaint tenha um construtor apropriado
//         // para converter os dados do Firestore para o objeto Complaint.
//         return Complaint.fromSnap(documentSnapshot);
//       } else {
//         return null;
//       }
//     } catch (error) {
//       print("Erro ao obter denúncia por ID: $error");
//       throw error.toString();
//     }
//   }

//   Future<String> likePost(String postId, String uid, List likes) async {
//     String res = "Some error occurred";
//     try {
//       if (likes.contains(uid)) {
//         // if the likes list contains the user uid, we need to remove it
//         _firestore.collection('complaints').doc(postId).update({
//           'likes': FieldValue.arrayRemove([uid])
//         });
//       } else {
//         // else we need to add uid to the likes array
//         _firestore.collection('complaints').doc(postId).update({
//           'likes': FieldValue.arrayUnion([uid])
//         });
//       }
//       res = 'success';
//     } catch (err) {
//       res = err.toString();
//     }
//     return res;
//   }

//   Future<String> deslikePost(String postId, String uid, List likes) async {
//     String res = "Some error occurred";
//     try {
//       if (likes.contains(uid)) {
//         // if the likes list contains the user uid, we need to remove it
//         _firestore.collection('complaints').doc(postId).update({
//           'deslikes': FieldValue.arrayRemove([uid])
//         });
//       } else {
//         // else we need to add uid to the deslikes array
//         _firestore.collection('complaints').doc(postId).update({
//           'deslikes': FieldValue.arrayUnion([uid])
//         });
//       }
//       res = 'success';
//     } catch (err) {
//       res = err.toString();
//     }
//     return res;
//   }

//   // Cancelar a inscrição quando necessário (por exemplo, no dispose de um StatefulWidget)
//   void cancelComplaintsStream(StreamSubscription<QuerySnapshot> subscription) {
//     subscription.cancel();
//   }
// }
