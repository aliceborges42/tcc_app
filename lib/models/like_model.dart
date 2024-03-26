class Like {
  int id;
  DateTime createdAt;
  DateTime updatedAt;
  int complaintId;
  int userId;

  Like({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.complaintId,
    required this.userId,
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      complaintId: json['complaint_id'],
      userId: json['user_id'],
    );
  }
}
