class Member {
  final int userId;
  final String username;
  final String email;
  final String? profilePictureUrl;
  final String role;
  final DateTime joinedAt;

  Member({
    required this.userId,
    required this.username,
    required this.email,
    this.profilePictureUrl,
    required this.role,
    required this.joinedAt,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      userId: json['user_id'],
      username: json['username'],
      email: json['email'],
      profilePictureUrl: json['profile_picture_url'],
      role: json['role'],
      joinedAt: DateTime.parse(json['joined_at']),
    );
  }
}

class Jar {
  final int id;
  final String name;
  final int ownerId;
  final String? styleSettings;
  final DateTime createdAt;
  final String? userRole;
  final int? memberCount;
  final List<Member>? members;

  Jar({
    required this.id,
    required this.name,
    required this.ownerId,
    this.styleSettings,
    required this.createdAt,
    this.userRole,
    this.memberCount,
    this.members,
  });

  factory Jar.fromJson(Map<String, dynamic> json) {
    return Jar(
      id: json['container_id'],
      name: json['name'],
      ownerId: json['owner_id'],
      styleSettings: json['jar_style_settings'],
      createdAt: DateTime.parse(json['created_at']),
      userRole: json['user_role'],
      memberCount: json['member_count'],
      members: json['members'] != null
          ? (json['members'] as List).map((i) => Member.fromJson(i)).toList()
          : null,
    );
  }
}
