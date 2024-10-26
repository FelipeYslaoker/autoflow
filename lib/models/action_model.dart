class ActionModel {
  final String id;
  final String name;
  final String path;
  final String branch;

  ActionModel({
    required this.id,
    required this.name,
    required this.path,
    required this.branch,
  });

  factory ActionModel.fromJson(Map<String, dynamic> json) {
    String htmlUrl = json['html_url'];
    String branch = htmlUrl.split('/blob/')[1].split('/')[0];

    return ActionModel(
      id: json['id'].toString(),
      name: json['name'],
      path: json['path'],
      branch: branch,
    );
  }
}
