class Jar {
  final int id;
  final String name;
  final int ownerId;
  final String? styleSettings;
  final DateTime createdAt;
  final String? userRole;
  final int? memberCount;

  Jar({
    required this.id,
    required this.name,
    required this.ownerId,
    this.styleSettings,
    required this.createdAt,
    this.userRole,
    this.memberCount,
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
    );
  }
}
