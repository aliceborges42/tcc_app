import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tcc_app/models/security_button_model.dart';

class SecurityButtonMethods {
  Future<List<SecurityButton>> getAllSecurityButtons() async {
    var uri = Uri.parse('https://atenta-api.onrender.com/security_buttons');

    try {
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        // Converter a resposta JSON em uma lista de Complaint
        List<dynamic> data = json.decode(response.body);
        List<SecurityButton> complaints =
            data.map((json) => SecurityButton.fromJson(json)).toList();
        // complaints.map((e) => print(e.description));
        return complaints;
      } else {
        throw Exception('Failed to load security buttons');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  Stream<List<SecurityButton>> getAllSecurityButtonsStream() async* {
    try {
      while (true) {
        var securityButtons = await getAllSecurityButtons();
        yield securityButtons;
        await Future.delayed(Duration(minutes: 1)); // Atualizar a cada minuto
      }
    } catch (e) {
      print('Erro ao obter transmissão de botoes de segurança: $e');
      yield []; // Emitir uma lista vazia em caso de erro
    }
  }
}
