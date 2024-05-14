import 'package:http/http.dart' as http;
import 'dart:convert';

class DataMethods {
  Future<Map<String, dynamic>> fetchComplaintsByMonth(
      String? complaintTypeId, String? typeSpecificationId) async {
    final url = Uri.parse(
        'https://atenta-api.onrender.com/complaints/number_of_complaints_by_month');

    Map<String, String> queryParams = {};
    if (complaintTypeId != null && complaintTypeId.isNotEmpty) {
      queryParams['complaint_type_id'] = complaintTypeId;
    }
    if (typeSpecificationId != null && typeSpecificationId.isNotEmpty) {
      queryParams['type_specification_id'] = typeSpecificationId;
    }

    final response = await http.get(url.replace(queryParameters: queryParams));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load complaints by month');
    }
  }

  Future<Map<String, dynamic>> fetchResolutionRateByMonth(
      String? complaintTypeId, String? typeSpecificationId) async {
    final url = Uri.parse(
        'https://atenta-api.onrender.com/complaints/resolved_complaints_by_month');

    Map<String, String> queryParams = {};
    if (complaintTypeId != null && complaintTypeId.isNotEmpty) {
      queryParams['complaint_type_id'] = complaintTypeId;
    }
    if (typeSpecificationId != null && typeSpecificationId.isNotEmpty) {
      queryParams['type_specification_id'] = typeSpecificationId;
    }

    final response = await http.get(url.replace(queryParameters: queryParams));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load rasolutions rate by month');
    }
  }
}
