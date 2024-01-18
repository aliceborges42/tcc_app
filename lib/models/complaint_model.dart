import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// TODO: adicionar tipo de denuncia (situação ou desordem) e o tipo de cada um
class Complaint {
  final String description;
  final String uid;
  final String name;
  final String complaintId;
  final DateTime datePublished;
  final List<String> imagesUrl;
  final likes;
  final deslikes;
  // final Bool resolved;
  // final Bool anonymous;
  final GeoPoint? local;
  final DateTime dateOfOccurrence;
  final DateTime hourOfOccurrence;
  final String complaintType;
  final String typeSpecification;

  const Complaint(
      {required this.description,
      required this.uid,
      required this.name,
      required this.complaintId,
      required this.datePublished,
      required this.imagesUrl,
      required this.likes,
      required this.deslikes,
      // required this.resolved,
      // required this.anonymous,
      required this.local,
      required this.dateOfOccurrence,
      required this.hourOfOccurrence,
      required this.complaintType,
      required this.typeSpecification});

  static Complaint fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Complaint(
      description: snapshot["description"] ?? "",
      uid: snapshot["uid"] ?? "",
      complaintId: snapshot["complaintId"] ?? "",
      datePublished:
          (snapshot["datePublished"] as Timestamp?)?.toDate() ?? DateTime.now(),
      name: snapshot["name"] ?? "",
      imagesUrl: List<String>.from(snapshot['imagesUrl'] ?? []),
      likes: List<String>.from(snapshot['likes'] ?? []),
      deslikes: List<String>.from(snapshot['deslikes'] ?? []),
      local: snapshot['local'] as GeoPoint?,
      dateOfOccurrence:
          (snapshot['dateOfOccurrence'] as Timestamp?)?.toDate() ??
              DateTime.now(),
      hourOfOccurrence:
          (snapshot['hourOfOccurrence'] as Timestamp?)?.toDate() ??
              DateTime.now(),
      complaintType: snapshot["complaintType"] ?? "",
      typeSpecification: snapshot["typeSpecification"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "description": description,
        "uid": uid,
        "complaintId": complaintId,
        "datePublished": datePublished,
        'imagesUrl': imagesUrl,
        'likes': likes,
        'deslikes': deslikes,
        // 'resolved': resolved,
        // 'anonymous': anonymous,
        'local': local,
        'dateOfOccurrence': dateOfOccurrence,
        'hourOfOccurrence': hourOfOccurrence,
        'complaintType': complaintType,
        'typeSpecification': typeSpecification,
      };
}
