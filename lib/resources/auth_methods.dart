import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcc_app/models/user_model.dart' as model;
import 'package:tcc_app/models/user_model.dart';

class AuthMethods {
  static const String baseUrl = 'http://localhost:3000';

  Future<User> getUserDetails(String token) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/member_details'), // Endpoint da API para obter detalhes do usuário
      headers: <String, String>{
        'Authorization':
            'Bearer $token', // Passando o token JWT nos cabeçalhos da solicitação
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return User(
        name: responseData['name'],
        uid: responseData['id'],
        email: responseData['email'],
        cpf: responseData['cpf'],
      );
    } else {
      throw Exception('Failed to get user details');
    }
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<bool> isLogged() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      // return true;
      try {
        await getUserDetails(token);
        return true;
      } catch (e) {
        print(e);
        return false;
      }
    } else {
      return false;
    }
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String name,
    required String cpf,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'user': {
          'email': email,
          'password': password,
          'cpf': cpf,
          'name': name,
        }
      }),
    );

    if (response.statusCode == 200) {
      return 'success';
    } else {
      throw Exception('Failed to sign up');
    }
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/sign_in'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'user': {
          'email': email,
          'password': password,
        }
      }),
    );

    if (response.statusCode == 200) {
      final authHeader = response.headers['authorization'];
      if (authHeader != null && authHeader.startsWith('Bearer ')) {
        final token = authHeader.substring(7); // Remove o prefixo 'Bearer '

        // Salva o token JWT no SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
      } else {
        throw Exception('Token JWT não encontrado no cabeçalho de resposta');
      }
    } else {
      throw Exception('Falha ao fazer login');
    }
  }

  Future<void> signOut(String token) async {
    final response = await http.delete(
      Uri.parse(
          '$baseUrl/users/sign_out'), // Endpoint da API para obter detalhes do usuário
      headers: <String, String>{
        'Authorization':
            'Bearer $token', // Passando o token JWT nos cabeçalhos da solicitação
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get user details');
    }
  }
}

final authMethods = AuthMethods();
