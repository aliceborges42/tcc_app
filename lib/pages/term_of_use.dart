import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';

class TermsOfUsePage extends StatefulWidget {
  @override
  _TermsOfUsePageState createState() => _TermsOfUsePageState();
}

class _TermsOfUsePageState extends State<TermsOfUsePage> {
  String _termsOfUse = 'Carregando...';

  @override
  void initState() {
    super.initState();
    _fetchTermsOfUse();
  }

  Future<void> _fetchTermsOfUse() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/term_of_uses/2'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _termsOfUse = data['content'];
      });
    } else {
      setState(() {
        _termsOfUse = 'Erro ao carregar os Termos de Uso';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Termos de Uso'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: _buildTermsOfUseText(),
      ),
    );
  }

  // Widget _buildTermsOfUseText() {
  //   final List<String> sections = _termsOfUse.split('\n\n');

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: sections.map((section) {
  //       return Padding(
  //         padding: const EdgeInsets.only(bottom: 16.0),
  //         // child: Text(
  //         //   section,
  //         //   style: TextStyle(
  //         //     fontSize: 16,
  //         //     fontWeight: FontWeight.normal,
  //         //   ),
  //         // ),
  //         child: Markdown(data: section),
  //       );
  //     }).toList(),
  //   );
  // }
  Widget _buildTermsOfUseText() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(8.0),
      child: MarkdownBody(
        data: _termsOfUse,
        styleSheet: MarkdownStyleSheet(
          textScaleFactor: 1.1,
          // Adicione estilos personalizados aqui, se necessário
        ),
      ),
    );
  }
}
