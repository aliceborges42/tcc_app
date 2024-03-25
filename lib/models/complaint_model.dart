class Complaint {
  int id;
  String description;
  String? status;
  double latitude;
  double longitude;
  DateTime hour;
  DateTime date;
  DateTime createdAt;
  DateTime updatedAt;
  int complaintTypeId;
  int typeSpecificationId;
  int userId;
  ComplaintType complaintType;
  TypeSpecification typeSpecification;
  List<String>? images;

  Complaint({
    required this.id,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.hour,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.complaintTypeId,
    required this.typeSpecificationId,
    required this.userId,
    required this.complaintType,
    required this.typeSpecification,
    this.images,
    this.status,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'],
      description: json['description'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      hour: DateTime.parse(json['hour']),
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      complaintTypeId: json['complaint_type_id'],
      typeSpecificationId: json['type_specification_id'],
      userId: json['user_id'],
      complaintType: ComplaintType.fromJson(json['complaint_type']),
      typeSpecification: TypeSpecification.fromJson(json['type_specification']),
      images: List<String>.from(json['images'] ?? []),
      status: json['status'] ?? 'Não Resolvido',
    );
  }
}

class ComplaintType {
  int id;
  String classification;

  ComplaintType({
    required this.id,
    required this.classification,
  });

  factory ComplaintType.fromJson(Map<String, dynamic> json) {
    return ComplaintType(
      id: json['id'],
      classification: json['classification'],
    );
  }
}

class TypeSpecification {
  int id;
  String specification;

  TypeSpecification({
    required this.id,
    required this.specification,
  });

  factory TypeSpecification.fromJson(Map<String, dynamic> json) {
    return TypeSpecification(
      id: json['id'],
      specification: json['specification'],
    );
  }
}
