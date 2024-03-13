import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tcc_app/complaint/complaint_form.dart';
import 'package:tcc_app/pages/map_page.dart';
import 'package:tcc_app/utils/colors.dart';

class AddComplaintPage extends StatelessWidget {
  AddComplaintPage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  // sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: white,
        appBar: AppBar(
          title: const Text(
            'Nova denúncia',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: white,
          elevation: 1,
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(3.0),
              child: Container(
                color: lightGray,
                height: 1,
              )),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
            color: Colors.black,
          ),
        ),
        body: const Padding(
          padding: EdgeInsets.only(top: 24.0),
          child: ComplaintForm(),
        ));
  }
}
