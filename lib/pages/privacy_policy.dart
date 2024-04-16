import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PrivacyPolicyPage extends StatefulWidget {
  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  String _privacyPolicy = 'Carregando...';

  @override
  void initState() {
    super.initState();
    _fetchPrivacyPolicy();
  }

  Future<void> _fetchPrivacyPolicy() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/privacy_policies/2'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _privacyPolicy = data['content'];
      });
    } else {
      setState(() {
        _privacyPolicy = 'Erro ao carregar a Plítica de Privacidade';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Política de Privacidade'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: _buildTermsOfUseText(),
      ),
    );
  }

  Widget _buildTermsOfUseText() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(8.0),
      child: MarkdownBody(
        data: _privacyPolicy,
        styleSheet: MarkdownStyleSheet(
          textScaleFactor: 1.1,
          // Adicione estilos personalizados aqui, se necessário
        ),
      ),
    );
  }
}
