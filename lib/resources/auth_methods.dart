import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
          avatar: responseData['avatar_url']);
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

  Future<void> updateUser(
      {String? email,
      required String password,
      String? name,
      String? cpf,
      dynamic avatar}) async {
    var uri = Uri.parse('$baseUrl/member_update');
    var request = http.MultipartRequest('PATCH', uri);
    String? authToken =
        await authMethods.getToken(); // Obtendo token de autorização

    if (authToken != null) {
      request.headers['Authorization'] =
          'Bearer $authToken'; // Adicionando o token de autorização ao cabeçalho
    } else {
      print('Erro: Token de autorização não encontrado.');
      // Tratar o caso em que o token de autorização não foi encontrado
      return;
    }
    request.headers['Authorization'] = 'Bearer $authToken';
    if (cpf != null) {
      request.fields['user[cpf]'] = cpf;
    }
    if (name != null) {
      request.fields['user[name]'] = name;
    }
    if (email != null) {
      request.fields['user[email]'] = email;
    }
    request.fields['users[password]'] = password;

    if (avatar != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'user[avatar]', avatar.path,
          filename: 'avatar_user_$email.jpg',
          contentType: MediaType('image', '/*')));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      print('Complaint successfully posted!');
    } else {
      throw Exception('Failed to update user');
    }
  }

  Future<String> updatePassword({
    required String newPassword,
    required String currentPassowrd,
    required String passwordConfirmation,
  }) async {
    String? authToken = await authMethods.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/update_password'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $authToken'
      },
      body: jsonEncode(<String, dynamic>{
        'user': {
          "password": newPassword,
          "current_password": currentPassowrd,
          "password_confirmation": passwordConfirmation
        }
      }),
    );

    if (response.statusCode == 200) {
      return 'success';
    } else {
      throw Exception('Failed to update password');
    }
  }

  Future<String> deleteAccount({required String id}) async {
    String? authToken = await authMethods.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/member_destroy/'),
      headers: <String, String>{'Authorization': 'Bearer $authToken'},
    );

    print(response.statusCode);
    if (response.statusCode == 204) {
      // Remova o token JWT do armazenamento local
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');

      return 'success';
    } else {
      throw Exception('Failed to delete user');
    }
  }

  Future<String> forgotPassword({required String email}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return 'success';
    } else {
      throw Exception('Failed to send forgot password request');
    }
  }

  Future<String> resetPassword({
    required String email,
    required String newPassword,
    required String resetToken,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': newPassword,
        'password_confirmation': passwordConfirmation,
        'token': resetToken,
      }),
    );

    if (response.statusCode == 200) {
      return 'success';
    } else {
      throw Exception('Failed to reset password');
    }
  }
}

final authMethods = AuthMethods();
