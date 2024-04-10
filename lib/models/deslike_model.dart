class Deslike {
  int id;
  DateTime createdAt;
  DateTime updatedAt;
  int complaintId;
  int userId;

  Deslike({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.complaintId,
    required this.userId,
  });

  factory Deslike.fromJson(Map<String, dynamic> json) {
    return Deslike(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      complaintId: json['complaint_id'],
      userId: json['user_id'],
    );
  }
}
