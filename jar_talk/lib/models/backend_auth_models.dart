class FirebaseAuthRequest {
  final String firebaseToken;
  final String? username;

  FirebaseAuthRequest({required this.firebaseToken, this.username});

  Map<String, dynamic> toJson() => {
    "firebase_token": firebaseToken,
    if (username != null) "username": username,
  };
}

class AuthResponse {
  final String accessToken;
  final UserResponse user;

  AuthResponse({required this.accessToken, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'],
      user: UserResponse.fromJson(json['user']),
    );
  }
}

class UserResponse {
  final int id;
  final String email;
  final String? username;
  final String? avatarUrl;

  UserResponse({
    required this.id,
    required this.email,
    this.username,
    this.avatarUrl,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['user_id'],
      email: json['email'],
      username: json['username'],
      avatarUrl: json['profile_picture_url'],
    );
  }
}
