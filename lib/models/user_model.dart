class UserModel {
  final int id;
  final String name;
  final String username;
  final String avatarUrl;
  final String bio;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
    required this.bio,
  });

  factory UserModel.fromMap(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      username: json['login'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
    );
  }
}
