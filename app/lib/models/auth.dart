class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class LoginResponse {
  final String accessToken;
  final User? user;

  LoginResponse({
    required this.accessToken,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] ?? json['access_token'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class User {
  final int id;
  final String email;
  final String? name;

  User({
    required this.id,
    required this.email,
    this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'],
    );
  }
}

