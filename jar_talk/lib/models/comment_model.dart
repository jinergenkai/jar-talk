// Preview version for enriched slip response (recent 3 comments)
class CommentPreview {
  final int commentId;
  final int authorId;
  final String? authorUsername;
  final String? authorProfilePicture;
  final String textContent;
  final DateTime createdAt;

  CommentPreview({
    required this.commentId,
    required this.authorId,
    this.authorUsername,
    this.authorProfilePicture,
    required this.textContent,
    required this.createdAt,
  });

  factory CommentPreview.fromJson(Map<String, dynamic> json) {
    return CommentPreview(
      commentId: json['comment_id'] as int,
      authorId: json['author_id'] as int,
      authorUsername: json['author_username'] as String?,
      authorProfilePicture: json['author_profile_picture'] as String?,
      textContent: json['text_content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

// Full comment with all details
class Comment {
  final int commentId;
  final int slipId;
  final int authorId;
  final String textContent;
  final DateTime createdAt;
  final String? authorUsername;
  final String? authorEmail;
  final String? authorProfilePicture;

  Comment({
    required this.commentId,
    required this.slipId,
    required this.authorId,
    required this.textContent,
    required this.createdAt,
    this.authorUsername,
    this.authorEmail,
    this.authorProfilePicture,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['comment_id'] as int,
      slipId: json['slip_id'] as int,
      authorId: json['author_id'] as int,
      textContent: json['text_content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      authorUsername: json['author_username'] as String?,
      authorEmail: json['author_email'] as String?,
      authorProfilePicture: json['author_profile_picture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment_id': commentId,
      'slip_id': slipId,
      'author_id': authorId,
      'text_content': textContent,
      'created_at': createdAt.toIso8601String(),
      'author_username': authorUsername,
      'author_email': authorEmail,
      'author_profile_picture': authorProfilePicture,
    };
  }
}
