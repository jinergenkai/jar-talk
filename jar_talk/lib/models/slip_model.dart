import 'package:jar_talk/models/media_model.dart';

class Slip {
  final int id;
  final int containerId;
  final int authorId;
  final String? title;
  final String? emotion;
  final String textContent;
  final DateTime createdAt;
  final String? locationData;
  final String? authorUsername;
  final String? authorEmail;
  final List<Media>? media;

  Slip({
    required this.id,
    required this.containerId,
    required this.authorId,
    this.title,
    this.emotion,
    required this.textContent,
    required this.createdAt,
    this.locationData,
    this.authorUsername,
    this.authorEmail,
    this.media,
  });

  factory Slip.fromJson(Map<String, dynamic> json) {
    return Slip(
      id: json['slip_id'],
      containerId: json['container_id'],
      authorId: json['author_id'],
      title: json['title'],
      emotion: json['emotion'],
      textContent: json['text_content'],
      createdAt: DateTime.parse(json['created_at']),
      locationData: json['location_data'],
      authorUsername: json['author_username'],
      authorEmail: json['author_email'],
      media: json['media'] != null
          ? (json['media'] as List).map((i) => Media.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'slip_id': id,
    'container_id': containerId,
    'author_id': authorId,
    'title': title,
    'emotion': emotion,
    'text_content': textContent,
    'created_at': createdAt.toIso8601String(),
    'location_data': locationData,
    'author_username': authorUsername,
    'author_email': authorEmail,
    'media': media?.map((e) => e.toJson()).toList(),
  };
}
