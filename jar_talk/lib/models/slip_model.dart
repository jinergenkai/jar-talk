import 'package:jar_talk/models/media_model.dart';
import 'package:jar_talk/models/comment_model.dart';
import 'package:jar_talk/models/reaction_model.dart';

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
  final String? authorProfilePicture;
  final List<Media>? media;
  // Comment & Reaction data from enriched response
  final List<CommentPreview>? comments;
  final int commentCount;
  final List<ReactionPreview>? reactions;
  final int reactionCount;

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
    this.authorProfilePicture,
    this.media,
    this.comments,
    this.commentCount = 0,
    this.reactions,
    this.reactionCount = 0,
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
      authorProfilePicture: json['author_profile_picture'],
      media: json['media'] != null
          ? (json['media'] as List).map((i) => Media.fromJson(i)).toList()
          : null,
      comments: json['comments'] != null
          ? (json['comments'] as List).map((i) => CommentPreview.fromJson(i)).toList()
          : null,
      commentCount: json['comment_count'] ?? 0,
      reactions: json['reactions'] != null
          ? (json['reactions'] as List).map((i) => ReactionPreview.fromJson(i)).toList()
          : null,
      reactionCount: json['reaction_count'] ?? 0,
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
