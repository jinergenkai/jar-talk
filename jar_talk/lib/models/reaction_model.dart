// Preview version for enriched slip response (reaction summary)
class ReactionPreview {
  final String reactionType;
  final int count;

  ReactionPreview({
    required this.reactionType,
    required this.count,
  });

  factory ReactionPreview.fromJson(Map<String, dynamic> json) {
    return ReactionPreview(
      reactionType: json['reaction_type'] as String,
      count: json['count'] as int,
    );
  }
}

// Full reaction with user details
class Reaction {
  final int slipReactionId;
  final int slipId;
  final int userId;
  final String reactionType;
  final DateTime createdAt;
  final String? username;
  final String? profilePicture;

  Reaction({
    required this.slipReactionId,
    required this.slipId,
    required this.userId,
    required this.reactionType,
    required this.createdAt,
    this.username,
    this.profilePicture,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      slipReactionId: json['slip_reaction_id'] as int,
      slipId: json['slip_id'] as int,
      userId: json['user_id'] as int,
      reactionType: json['reaction_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      username: json['username'] as String?,
      profilePicture: json['profile_picture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slip_reaction_id': slipReactionId,
      'slip_id': slipId,
      'user_id': userId,
      'reaction_type': reactionType,
      'created_at': createdAt.toIso8601String(),
      'username': username,
      'profile_picture': profilePicture,
    };
  }
}

class ReactionSummary {
  final String reactionType;
  final int count;
  final List<ReactionUser> users;

  ReactionSummary({
    required this.reactionType,
    required this.count,
    required this.users,
  });

  factory ReactionSummary.fromJson(Map<String, dynamic> json) {
    return ReactionSummary(
      reactionType: json['reaction_type'] as String,
      count: json['count'] as int,
      users: (json['users'] as List<dynamic>)
          .map((user) => ReactionUser.fromJson(user as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ReactionUser {
  final int userId;
  final String username;
  final String? profilePicture;

  ReactionUser({
    required this.userId,
    required this.username,
    this.profilePicture,
  });

  factory ReactionUser.fromJson(Map<String, dynamic> json) {
    return ReactionUser(
      userId: json['user_id'] as int,
      username: json['username'] as String,
      profilePicture: json['profile_picture'] as String?,
    );
  }
}
