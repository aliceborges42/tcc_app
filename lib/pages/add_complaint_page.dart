import 'package:flutter/material.dart';
import 'package:tcc_app/complaint/complaint_form.dart';
import 'package:tcc_app/utils/colors.dart';

class AddComplaintPage extends StatelessWidget {
  const AddComplaintPage({super.key});

  // sign user out method

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
          tooltip: 'Voltar',
        ),
      ),
      body: const ComplaintForm(),
    );
  }
}
