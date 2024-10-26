import 'package:autoflow/services/github_service.dart';
import 'package:flutter/material.dart';
import 'package:autoflow/models/repository_model.dart';
import 'package:autoflow/widgets/repository_tile.dart'; // Importa o RepositoryTile

class OrganizationPage extends StatefulWidget {
  final String organizationName;
  final GithubService githubService;

  const OrganizationPage({
    super.key,
    required this.organizationName,
    required this.githubService,
  });

  @override
  State<OrganizationPage> createState() => _OrganizationPageState();
}

class _OrganizationPageState extends State<OrganizationPage> {
  late Future<List<RepositoryModel>> _repositoriesFuture;

  @override
  void initState() {
    super.initState();
    // Carrega os repositórios da organização usando o githubService passado via parâmetro
    _repositoriesFuture = widget.githubService
        .getOrganizationRepositories(widget.organizationName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.organizationName),
      ),
      body: FutureBuilder<List<RepositoryModel>>(
        future: _repositoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar repositórios: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final repositories = snapshot.data!;
            return ListView.builder(
              itemCount: repositories.length,
              itemBuilder: (context, index) {
                final repository = repositories[index];
                return RepositoryTile(
                  repository: repository,
                  githubService: widget.githubService,
                ); // Substitui LyListTile pelo RepositoryTile
              },
            );
          } else {
            return const Center(
              child: Text('Nenhum repositório encontrado.'),
            );
          }
        },
      ),
    );
  }
}
