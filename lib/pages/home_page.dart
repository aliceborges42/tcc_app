import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tcc_app/pages/add_complaint_page.dart';
import 'package:tcc_app/pages/map_page.dart';
import 'package:tcc_app/resources/auth_methods.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // final user = FirebaseAuth.instance.currentUser!;

  // sign user out method
  void signUserOut() async {
    String? token =
        await AuthMethods().getToken(); // Obtém o token do SharedPreferences
    if (token != null) {
      try {
        await AuthMethods()
            .signOut(token); // Chama a função signOut passando o token
        // Se o logout for bem-sucedido, você pode limpar o token do SharedPreferences ou realizar outras ações necessárias
      } catch (error) {
        print('Erro durante o logout: $error');
        // Lidar com erros durante o logout, se necessário
      }
    } else {
      print(
          'Nenhum token encontrado'); // Tratar caso não haja token no SharedPreferences
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          actions: [
            IconButton(
              onPressed: signUserOut,
              icon: const Icon(Icons.logout),
            )
          ],
        ),
        body: const MapSample());
  }
}
