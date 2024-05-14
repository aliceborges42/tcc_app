import 'package:flutter/material.dart';
import 'package:tcc_app/pages/charts_page.dart';
import 'package:tcc_app/pages/list_complaints_page.dart';
import 'package:tcc_app/pages/map_page.dart';
import 'package:tcc_app/pages/perfil_page.dart';
import 'package:tcc_app/resources/auth_methods.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const MapSample(),
    ComplaintListPage(),
    const PerfilPage(),
    ChartsPage(), // Adicionando a página DataChartsPage à lista de widgets
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Mapa',
              backgroundColor: Colors.white),
          BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Denúncias',
              backgroundColor: Colors.white),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
              backgroundColor: Colors.white),
          BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart),
              label: 'Gráficos',
              backgroundColor: Colors.white),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple[600],
        unselectedItemColor: Colors.grey[700],
        backgroundColor: Colors.white,
        onTap: (index) {
          _onItemTapped(index);
        },
      ),
    );
  }
}
