import 'package:flutter/widgets.dart';
import 'package:tcc_app/models/user_model.dart';
import 'package:tcc_app/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final AuthMethods _authMethods = AuthMethods();

  User? get getUser => _user;

  Future<void> refreshUser() async {
    final token = await _authMethods.getToken();
    if (token != null) {
      User user = await _authMethods.getUserDetails(token);
      _user = user;
      notifyListeners();
    } else {
      // Caso não seja possível obter o token, você pode tomar alguma ação aqui
    }
  }
}
