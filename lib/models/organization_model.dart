class OrganizationModel {
  final String login;
  final String description;
  final String avatarUrl;

  OrganizationModel({
    required this.login,
    required this.description,
    required this.avatarUrl,
  });

  factory OrganizationModel.fromMap(Map<String, dynamic> map) {
    return OrganizationModel(
      login: map['login'],
      description: map['description'] ?? 'No description',
      avatarUrl: map['avatar_url'],
    );
  }
}
