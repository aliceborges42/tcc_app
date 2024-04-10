class SecurityButton {
  int id;
  DateTime createdAt;
  DateTime updatedAt;
  double latitude;
  double longitude;
  String name;

  SecurityButton({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.latitude,
    required this.longitude,
    required this.name,
  });

  factory SecurityButton.fromJson(Map<String, dynamic> json) {
    return SecurityButton(
        id: json['id'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        latitude: json['latitude'],
        longitude: json['longitude'],
        name: json['name']);
  }
}
