import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:nested_navigation/ui/session/login.dart';
import 'package:tcc_app/pages/home_page.dart';
import 'package:tcc_app/pages/login_page.dart';
// import 'homepage.dart';
// import 'utils/session_manager.dart';
import 'package:device_preview/device_preview.dart';
import 'resources/auth_methods.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // runApp(MyApp());
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MyApp(), // Wrap your app
    ),
  );
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
            // useInherit/edMediaQuery: true,
            locale: DevicePreview.locale(context),
            builder: DevicePreview.appBuilder,
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
