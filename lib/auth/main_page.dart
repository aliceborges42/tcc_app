import 'package:flutter/material.dart';
import 'package:tcc_app/auth/auth_page.dart';
import 'package:tcc_app/resources/auth_methods.dart';
import '../pages/home_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
        future: authMethods.isLogged(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data == true) {
            return HomePage();
          } else {
            return AuthPage();
          }
        },
      ),
    );
  }
}
