class RepositoryModel {
  final String name;
  final String description;
  final String htmlUrl;
  final String login; // Novo campo para o owner (login)

  RepositoryModel({
    required this.name,
    required this.description,
    required this.htmlUrl,
    required this.login, // Incluímos login no construtor
  });

  factory RepositoryModel.fromMap(Map<String, dynamic> map) {
    return RepositoryModel(
      name: map['name'],
      description: map['description'] ?? 'No description',
      htmlUrl: map['html_url'],
      login: map['owner']['login'], // Aqui extraímos o login do owner
    );
  }
}
