import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import './auth_methods.dart';
import 'dart:convert';
import 'package:tcc_app/models/complaint_model.dart';

class ComplaintMethods {
  Future<void> postComplaint(
      {required String description,
      required String complaintTypeId,
      required String typeSpecificationId,
      required double latitude,
      required double longitude,
      DateTime? hour,
      required DateTime date,
      List<dynamic>? images}) async {
    var uri = Uri.parse('http://localhost:3000/complaints');

    var request = http.MultipartRequest('POST', uri);
    final AuthMethods authMethods = AuthMethods(); // Instanciando AuthMethods
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
    request.fields['complaint[description]'] = description;
    request.fields['complaint[complaint_type_id]'] = complaintTypeId;
    request.fields['complaint[type_specification_id]'] = typeSpecificationId;
    request.fields['complaint[latitude]'] = latitude.toString();
    request.fields['complaint[longitude]'] = longitude.toString();
    request.fields['complaint[hour]'] = hour!.toString();
    request.fields['complaint[date]'] = date.toString();

    for (int i = 0; i < images!.length; i++) {
      var file = images[i];
      request.files.add(
        await http.MultipartFile.fromPath(
          'complaint[images][]',
          file.path,
          filename: 'image_$i.jpg', // Nome do arquivo
          contentType: MediaType('image', '/*'), // Tipo de conteúdo
        ),
      );
    }
    var response = await request.send();
    if (response.statusCode == 201) {
      print('Complaint successfully posted!');
    } else {
      print('Failed to post complaint: ${response.reasonPhrase}');
    }
  }

  Future<List<Complaint>> getAllComplaints() async {
    var uri = Uri.parse('http://localhost:3000/complaints');

    try {
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        print('olaa');
        // Converter a resposta JSON em uma lista de Complaint
        List<dynamic> data = json.decode(response.body);
        List<Complaint> complaints =
            data.map((json) => Complaint.fromJson(json)).toList();
        // complaints.map((e) => print(e.description));
        return complaints;
      } else {
        throw Exception('Failed to load complaints');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  Stream<List<Complaint>> getAllComplaintsStream() async* {
    try {
      while (true) {
        var complaints = await getAllComplaints();
        yield complaints;
        await Future.delayed(Duration(minutes: 1)); // Atualizar a cada minuto
      }
    } catch (e) {
      print('Erro ao obter transmissão de reclamações: $e');
      yield []; // Emitir uma lista vazia em caso de erro
    }
  }

  Future<Complaint> getComplaintById(String id) async {
    var uri = Uri.parse('http://localhost:3000/complaints/$id');

    try {
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        // Converter a resposta JSON em um objeto Complaint
        dynamic data = json.decode(response.body);
        return Complaint.fromJson(data);
      } else {
        throw Exception('Failed to load complaint');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  Future<List<TypeSpecification>> getTypeSpecifications() async {
    var uri = Uri.parse('http://localhost:3000/type_specifications');

    try {
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        // Retorna os dados convertidos de JSON
        List<dynamic> jsonData = json.decode(response.body);
        List<TypeSpecification> typeSpecifications = jsonData
            .map((jsonItem) => TypeSpecification.fromJson(jsonItem))
            .toList();
        return typeSpecifications;
      } else {
        throw Exception('Failed to load type specifications');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  Future<List<ComplaintType>> getComplaintTypes() async {
    var uri = Uri.parse('http://localhost:3000/complaint_types');

    try {
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        // Retorna os dados convertidos de JSON
        List<dynamic> jsonData = json.decode(response.body);
        List<ComplaintType> complaintTypes = jsonData
            .map((jsonItem) => ComplaintType.fromJson(jsonItem))
            .toList();
        return complaintTypes;
      } else {
        throw Exception('Failed to load type specifications');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }
}
