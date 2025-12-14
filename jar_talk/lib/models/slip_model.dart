class Slip {
  final int id;
  final int containerId;
  final int authorId;
  final String textContent;
  final DateTime createdAt;
  final String? locationData;
  final String? authorUsername;
  final String? authorEmail;

  Slip({
    required this.id,
    required this.containerId,
    required this.authorId,
    required this.textContent,
    required this.createdAt,
    this.locationData,
    this.authorUsername,
    this.authorEmail,
  });

  factory Slip.fromJson(Map<String, dynamic> json) {
    return Slip(
      id: json['slip_id'],
      containerId: json['container_id'],
      authorId: json['author_id'],
      textContent: json['text_content'],
      createdAt: DateTime.parse(json['created_at']),
      locationData: json['location_data'],
      authorUsername: json['author_username'],
      authorEmail: json['author_email'],
    );
  }

  Map<String, dynamic> toJson() => {
    'slip_id': id,
    'container_id': containerId,
    'author_id': authorId,
    'text_content': textContent,
    'created_at': createdAt.toIso8601String(),
    'location_data': locationData,
    'author_username': authorUsername,
    'author_email': authorEmail,
  };
}
