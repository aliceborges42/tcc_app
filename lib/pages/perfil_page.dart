// Importe as bibliotecas necessárias
import 'package:flutter/material.dart';
import 'package:tcc_app/pages/edit_perfil_page.dart';
import 'package:tcc_app/pages/list_user_complaint_page.dart';
import 'package:tcc_app/pages/login_page.dart';
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

  // Desloga o usuário e navega para a tela de login
  void signUserOut(BuildContext context) async {
    String? token = await AuthMethods().getToken();
    if (token != null) {
      try {
        await AuthMethods().signOut(token);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } catch (error) {
        print('Erro durante o logout: $error');
      }
    } else {
      print('Nenhum token encontrado');
    }
  }

  // Deleta a conta do usuário
  void deleteAccount(BuildContext context) async {
    try {
      String result = await authMethods.deleteAccount(
          id: ''); // Passe o ID do usuário se necessário
      if (result == 'success') {
        // Se a exclusão for bem-sucedida, deslogue o usuário
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        // Se a exclusão falhar, exiba uma mensagem de erro
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Erro'),
              content: Text('Falha ao deletar a conta do usuário.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      print('Erro durante a exclusão da conta: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black87,
        elevation: 1,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navega para a página de edição de perfil
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ComplaintUserListPage(),
                ),
              );
            },
          ),
        ],
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
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            user.avatar != null
                ? CircleAvatar(
                    radius: 75,
                    backgroundImage: NetworkImage(
                      user.avatar!,
                    ),
                  )
                : Container(
                    width: 155,
                    height: 155,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
            SizedBox(height: 14),
            Text(
              user.name,
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {
            //     // Navega para a página de edição de perfil
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => PerfilEditPage(user: user),
            //       ),
            //     );
            //   },
            //   child: Text('Editar Perfil'),
            // ),
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
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    Colors.deepPurple, // Define a cor do texto como preto
                elevation: 0, // Define a elevação do botão
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      4.0), // Define o raio do canto do botão
                  // s, // Define a cor da borda
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Minhas Denúncias',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor:
                    Colors.white, // Define a cor do texto como preto
                elevation: 0, // Define a elevação do botão
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      4.0), // Define o raio do canto do botão
                  side: BorderSide(
                      color: Colors.black87), // Define a cor da borda
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Alterar Senha',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onPressed: () {
                // Navega para a página de edição de perfil
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPassword(),
                  ),
                );
              },
            ),

            SizedBox(
              height: 35,
            ),
            OutlinedButton.icon(
              onPressed: () {
                signUserOut(context);
              },
              style: ButtonStyle(
                side: MaterialStateProperty.all<BorderSide>(
                  BorderSide(color: Colors.red),
                ),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              ),
              icon: Icon(
                Icons.logout,
                color: Colors.red,
              ),
              label: Text(
                'Sair',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Deletar Conta',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.red[800],
                backgroundColor:
                    Colors.red[100], // Define a cor do texto como preto
                elevation: 0, // Define a elevação do botão
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      4.0), // Define o raio do canto do botão
                  // side: BorderSide(color: Colors.red), // Define a cor da borda
                ),
              ),
              onPressed: () {
                // Exibe um diálogo de confirmação antes de deletar a conta
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Deletar Conta'),
                      content:
                          Text('Tem certeza de que deseja deletar sua conta?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            deleteAccount(context);
                          },
                          child: Text('Confirmar'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
