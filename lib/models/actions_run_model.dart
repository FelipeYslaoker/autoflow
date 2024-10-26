class ActionsRunModel {
  final String id;
  final String name;
  final String status;
  final String conclusion;
  final DateTime createdAt;
  final DateTime updatedAt;

  ActionsRunModel({
    required this.id,
    required this.name,
    required this.status,
    required this.conclusion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ActionsRunModel.fromJson(Map<String, dynamic> json) {
    return ActionsRunModel(
      id: json['id'].toString(),
      name: json['name'],
      status: json['status'],
      conclusion: json['conclusion'] ?? 'N/A',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
