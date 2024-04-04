import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:tcc_app/models/user_model.dart';
import 'dart:io';
import './auth_methods.dart';
import 'dart:convert';
import 'package:tcc_app/models/complaint_model.dart';
import 'package:tcc_app/models/like_model.dart';
import 'package:tcc_app/models/deslike_model.dart';
import 'package:collection/collection.dart';

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
    request.fields['complaint[status]'] = 'Não Resolvido';

    if (images != null && images.isNotEmpty) {
      for (int i = 0; i < images.length; i++) {
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
    }
    var response = await request.send();
    if (response.statusCode == 201) {
      print('Complaint successfully posted!');
    } else {
      print('Failed to post complaint: ${response.reasonPhrase}');
    }
  }

  Future<void> updateComplaint({
    required String complaintId,
    String? description,
    String? complaintTypeId,
    String? typeSpecificationId,
    double? latitude,
    double? longitude,
    String? status,
    DateTime? hour,
    DateTime? date,
    List<dynamic>? images,
    List<int>? removedImagesIds,
  }) async {
    var uri = Uri.parse('http://localhost:3000/complaints/$complaintId');

    final AuthMethods authMethods = AuthMethods();
    String? authToken = await authMethods.getToken();

    if (authToken == null) {
      print('Erro: Token de autorização não encontrado.');
      return;
    }

    var request = http.MultipartRequest('PATCH', uri);
    request.headers['Authorization'] = 'Bearer $authToken';
    if (description != null) {
      request.fields['complaint[description]'] = description;
    }
    if (status != null) {
      request.fields['complaint[status]'] = status;
    }
    if (complaintTypeId != null) {
      request.fields['complaint[complaint_type_id]'] = complaintTypeId;
    }
    if (typeSpecificationId != null) {
      request.fields['complaint[type_specification_id]'] = typeSpecificationId;
    }
    if (latitude != null) {
      request.fields['complaint[latitude]'] = latitude.toString();
    }
    if (longitude != null) {
      request.fields['complaint[longitude]'] = longitude.toString();
    }
    if (hour != null) request.fields['complaint[hour]'] = hour.toString();
    if (date != null) request.fields['complaint[date]'] = date.toString();

    if (removedImagesIds != null && removedImagesIds.isNotEmpty) {
      request.fields['complaint[removed_images_ids][]'] =
          removedImagesIds.join(',');
    }

    if (images != null && images.isNotEmpty) {
      for (int i = 0; i < images.length; i++) {
        var file = images[i];
        request.files.add(
          await http.MultipartFile.fromPath(
            'complaint[images][]',
            file.path,
            filename: 'image_$i.jpg',
            contentType: MediaType('image', '/*'),
          ),
        );
      }
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      print('Complaint successfully updated!');
    } else {
      print('Failed to update complaint: ${response.reasonPhrase}');
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

  Future<String> likeComplaint(String complaintId) async {
    var uri = Uri.parse('http://localhost:3000/likes/');

    String? authToken = await authMethods.getToken();

    final response = await http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken'
        },
        body: jsonEncode(<String, dynamic>{
          'like': {'complaint_id': complaintId}
        }));

    if (response.statusCode == 201) {
      return 'success';
    } else {
      throw Exception('Failed to like');
    }
  }

  Future<String> deslikeComplaint(String complaintId) async {
    var uri = Uri.parse('http://localhost:3000/deslikes/');

    String? authToken = await authMethods.getToken();

    final response = await http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken'
        },
        body: jsonEncode(<String, dynamic>{
          'deslike': {'complaint_id': complaintId}
        }));

    if (response.statusCode == 201) {
      return 'success';
    } else {
      throw Exception('Failed to deslike');
    }
  }

  Future<List<Like>> getComplaintLikes(String complaintId) async {
    print('veio like');
    var uri = Uri.parse('http://localhost:3000/complaints/$complaintId/likes');
    String? authToken = await authMethods.getToken();

    var response =
        await http.get(uri, headers: {'Authorization': 'Bearer $authToken'});

    if (response.statusCode == 200) {
      print('deu bom get like');

      // Converter a resposta JSON em um objeto Complaint
      List<dynamic> data = json.decode(response.body);
      List<Like> likes = data.map((json) => Like.fromJson(json)).toList();
      // likes.map((e) => print(e.id));
      return likes;
    } else {
      throw Exception('Failed to load complaint likes');
    }
  }

  Future<List<Deslike>> getComplaintDeslikes(String complaintId) async {
    print('veio deslike');
    var uri =
        Uri.parse('http://localhost:3000/complaints/$complaintId/deslikes');
    String? authToken = await authMethods.getToken();

    var response =
        await http.get(uri, headers: {'Authorization': 'Bearer $authToken'});

    if (response.statusCode == 200) {
      print('deu bom get deslike');

      // Converter a resposta JSON em um objeto Complaint
      List<dynamic> data = json.decode(response.body);
      List<Deslike> deslikes =
          data.map((json) => Deslike.fromJson(json)).toList();
      // deslikes.map((e) => print(e.id));
      return deslikes;
    } else {
      throw Exception('Failed to load complaint deslikes');
    }
  }

  Future<void> removeDislike(String deslikeId) async {
    try {
      var uri = Uri.parse('http://localhost:3000/deslikes/$deslikeId');
      String? authToken = await authMethods.getToken();

      final response = await http.delete(
        uri,
        headers: <String, String>{
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode >= 300) {
        throw Exception('Failed to remove dislike');
      }
    } catch (error) {
      print("Erro ao remover deslike: $error");
      rethrow;
    }
  }

  Future<void> removeLike(String likeId) async {
    try {
      var uri = Uri.parse('http://localhost:3000/likes/$likeId');
      String? authToken = await authMethods.getToken();

      final response = await http.delete(
        uri,
        headers: <String, String>{
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode >= 300) {
        throw Exception('Failed to remove like');
      }
    } catch (error) {
      print("Erro ao remover like: $error");
      rethrow;
    }
  }

  Future<void> dislikeOrRemoveDislike(String complaintId) async {
    try {
      String? authToken = await authMethods.getToken();
      if (authToken != null) {
        User currentUser = await authMethods.getUserDetails(authToken);
        List<Deslike> deslikes = await getComplaintDeslikes(complaintId);
        Deslike? userDeslike = deslikes
            .firstWhereOrNull((deslike) => deslike.userId == currentUser.uid);

        if (userDeslike != null) {
          // O usuário já deu deslike, então remova o deslike
          await removeDislike(userDeslike.id.toString());
        } else {
          // O usuário ainda não deu deslike, então adicione o deslike
          await deslikeComplaint(complaintId);
        }
      } else {
        throw Exception('Token JWT não encontrado');
      }
    } catch (error) {
      print("Erro ao dar ou remover deslike: $error");
      rethrow;
    }
  }

  Future<void> likeOrRemoveLike(String complaintId) async {
    try {
      String? authToken = await authMethods.getToken();
      if (authToken != null) {
        User currentUser = await authMethods.getUserDetails(authToken);
        List<Like> likes = await getComplaintLikes(complaintId);
        Like? userLike =
            likes.firstWhereOrNull((like) => like.userId == currentUser.uid);

        if (userLike != null) {
          await removeLike(userLike.id.toString());
        } else {
          await likeComplaint(complaintId);
        }
      } else {
        throw Exception('Token JWT não encontrado');
      }
    } catch (error) {
      print("Erro ao dar ou remover like: $error");
      rethrow;
    }
  }
}
