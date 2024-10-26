import 'package:autoflow/services/github_service.dart';
import 'package:autoflow/pages/repository_actions_page.dart';
import 'package:autoflow/ui/lists/ly_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:autoflow/models/repository_model.dart';

class RepositoryTile extends StatelessWidget {
  final RepositoryModel repository;
  final GithubService githubService;

  const RepositoryTile({
    super.key,
    required this.repository,
    required this.githubService,
  });

  @override
  Widget build(BuildContext context) {
    return LyListTile(
      title: Text('${repository.login}/${repository.name}'),
      subtitle: Text(repository.description),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RepositoryActionsPage(
              owner: repository.login,
              repo: repository,
              githubService: githubService,
            ),
          ),
        );
      },
    );
  }
}
