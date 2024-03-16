import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tcc_app/auth/main_page.dart';
import 'package:tcc_app/models/user_model.dart';
import 'package:tcc_app/pages/login_page.dart';
import 'package:tcc_app/providers/user_provider.dart';
import 'package:tcc_app/resources/auth_methods.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'To de olho app',
        home: AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return FutureBuilder(
      future: userProvider.refreshUser(),
      builder: (context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final user = userProvider.getUser;
          return user != null ? MainPage() : LoginPage();
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:tcc_app/auth/main_page.dart';
// import 'package:tcc_app/pages/login_page.dart';
// import 'package:tcc_app/providers/user_provider.dart';
// import 'firebase_options.dart';
// import 'package:provider/provider.dart';
// import 'package:tcc_app/resources/auth_methods.dart'; // Importe o AuthMethods para obter o token JWT

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(
//           create: (_) => UserProvider(),
//         ),
//       ],
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'To de olho app',
//         home: FutureBuilder(
//           future: _getToken(), // Obter token JWT
//           builder: (context, AsyncSnapshot<String?> snapshot) {
//             if (snapshot.connectionState == ConnectionState.done) {
//               if (snapshot.hasData) {
//                 return FutureBuilder(
//                   future: Provider.of<UserProvider>(context, listen: false)
//                       .refreshUser(snapshot
//                           .data!), // Atualizar usuário com base no token JWT
//                   builder: (context, AsyncSnapshot<void> snapshot) {
//                     if (snapshot.connectionState == ConnectionState.done) {
//                       return Provider.of<UserProvider>(context).getUser != null
//                           ? const MainPage()
//                           : const LoginPage();
//                     } else {
//                       return const Center(
//                         child: CircularProgressIndicator(),
//                       );
//                     }
//                   },
//                 );
//               } else {
//                 return const LoginPage();
//               }
//             } else {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }

//   Future<String?> _getToken() async {
//     final authMethods = AuthMethods();
//     return await authMethods.getToken();
//   }
// }
