import 'package:flutter/material.dart';
import 'package:tcc_app/pages/edit_perfil_page.dart';
import 'package:tcc_app/pages/list_user_complaint_page.dart';
import 'package:tcc_app/pages/new_password_page.dart';
import 'package:tcc_app/resources/auth_methods.dart';
import 'package:tcc_app/models/user_model.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({Key? key}) : super(key: key);

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  late Future<User> _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _getCurrentUser();
  }

  // Obtém o usuário atual
  Future<User> _getCurrentUser() async {
    try {
      String? authToken = await authMethods.getToken();
      User user = await authMethods.getUserDetails(authToken!);
      return user;
    } catch (error) {
      print("Erro ao carregar usuário atual: $error");
      rethrow;
    }
  }

  // Desloga o usuário
  void signUserOut() async {
    String? token = await AuthMethods().getToken();
    if (token != null) {
      try {
        await AuthMethods().signOut(token);
      } catch (error) {
        print('Erro durante o logout: $error');
      }
    } else {
      print('Nenhum token encontrado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Denúncia'),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _currentUser,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Erro ao carregar detalhes do usuário: ${snapshot.error}",
                ),
              );
            } else if (snapshot.hasData) {
              // Extrai o widget do perfil para melhor legibilidade
              return _buildUserProfile(snapshot.data as User);
            } else {
              return const Center(
                child:
                    Text("Erro desconhecido ao carregar detalhes de usuário."),
              );
            }
          },
        ),
      ),
    );
  }

  // Widget que exibe o perfil do usuário
  Widget _buildUserProfile(User user) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          user.avatar != null
              ? CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    user.avatar!,
                  ),
                )
              : CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1526800544336-d04f0cbfd700?q=80&w=2148&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                  ),
                ),
          SizedBox(height: 20),
          Text(
            user.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navega para a página de edição de perfil
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PerfilEditPage(user: user),
                ),
              );
            },
            child: Text('Editar Perfil'),
          ),
          ElevatedButton(
            onPressed: () {
              // Navega para a página de edição de perfil
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ComplaintUserListPage(),
                ),
              );
            },
            child: Text('Minhas Complaints'),
          ),
          GestureDetector(
            child: Text(
              'Alterar Senha',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              // Navega para a página de edição de perfil
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPassword(),
                ),
              );
            },
          ),
          GestureDetector(
            child: Text(
              'Sair',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: signUserOut,
          )
        ],
      ),
    );
  }
}
