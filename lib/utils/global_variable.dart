import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tcc_app/pages/map_page.dart';
import 'package:tcc_app/utils/colors.dart';

// import 'package:instagram_clone_flutter/screens/profile_screen.dart';
// import 'package:instagram_clone_flutter/screens/search_screen.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const MapSample(),
  // const SearchScreen(),
  // const AddPostScreen(),
  const Text('notifications'),
  // ProfileScreen(
  //   uid: FirebaseAuth.instance.currentUser!.uid,
  // ),
];

final myDecoration = InputDecoration(
  enabledBorder: const OutlineInputBorder(
    borderSide: BorderSide(color: grayBlack),
  ),
  focusedBorder: const OutlineInputBorder(
    borderSide: BorderSide(color: lightBlack),
  ),
  fillColor: white,
  filled: true,
  hintStyle: TextStyle(color: Colors.grey[500]),
);
