import 'package:flutter/material.dart';
// import 'package:nested_navigation/ui/session/login.dart';
import 'package:tcc_app/pages/home_page.dart';
import 'package:tcc_app/pages/login_page.dart';
// import 'homepage.dart';
// import 'utils/session_manager.dart';
import 'resources/auth_methods.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

class MyApp extends StatelessWidget {
  final AuthMethods authMethods = AuthMethods();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: authMethods.isLogged(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Se estiver esperando, mostra uma tela de carregamento
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else {
          // Quando a verificação estiver completa, decide qual tela exibir
          if (snapshot.hasData && snapshot.data!) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: HomePage(),
            );
          } else {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: LoginPage(),
            );
          }
        }
      },
    );
  }
}
