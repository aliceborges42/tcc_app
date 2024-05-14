import 'package:flutter/material.dart';
import 'package:tcc_app/pages/complaints_charts_page.dart';
import 'package:tcc_app/pages/resolutions_chart_page.dart';

class ChartsPage extends StatefulWidget {
  @override
  _ChartsPageState createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  int _selectedIndex = 0; // Índice da opção selecionada

  // Lista de páginas correspondentes às opções do menu
  final List<Widget> _pages = [
    ComplaintsChartsPage(),
    ResolutionsChart(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gráficos'),
        backgroundColor: Colors.grey[100],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Menu horizontal
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0; // Define o índice para Denúncias
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedIndex == 0
                                ? Colors.blue
                                : Colors
                                    .transparent, // Sublinha a opção selecionada
                            width: 2.0,
                          ),
                        ),
                      ),
                      child: Text(
                        'Denúncias',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color:
                              _selectedIndex == 0 ? Colors.blue : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1; // Define o índice para Resoluções
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedIndex == 1
                                ? Colors.blue
                                : Colors
                                    .transparent, // Sublinha a opção selecionada
                            width: 2.0,
                          ),
                        ),
                      ),
                      child: Text(
                        'Resoluções',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color:
                              _selectedIndex == 1 ? Colors.blue : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Página selecionada com base no índice
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
