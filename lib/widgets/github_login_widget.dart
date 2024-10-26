import 'package:autoflow/services/github_service.dart';
import 'package:autoflow/models/organization_model.dart';
import 'package:autoflow/models/repository_model.dart';
import 'package:autoflow/models/user_model.dart';
import 'package:autoflow/pages/organization_page.dart';
import 'package:autoflow/ui/lists/ly_list_tile.dart';
import 'package:autoflow/widgets/repository_tile.dart'; // Importando o RepositoryTile
import 'package:flutter/material.dart';

class GithubLoginWidget extends StatefulWidget {
  final GithubService githubService;

  const GithubLoginWidget({super.key, required this.githubService});

  @override
  State<GithubLoginWidget> createState() => _GithubLoginWidgetState();
}

class _GithubLoginWidgetState extends State<GithubLoginWidget> {
  UserModel? _user;
  List<RepositoryModel> _repositories = [];
  List<OrganizationModel> _organizations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _user = await widget.githubService.getUser();
      _repositories = await widget.githubService.getUserRepositories();
      _organizations = await widget.githubService.getUserOrganizations();
    } catch (e) {
      print('Erro ao carregar dados: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Flow'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _user != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Lado esquerdo: Perfil do usuário
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(_user!.avatarUrl),
                            radius: 50,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Bem-vindo, ${_user!.name}!',
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Bio: ${_user!.bio}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              await widget.githubService.logout();
                              setState(() {
                                _user = null;
                              });
                            },
                            child: const Text('Sair'),
                          ),
                        ],
                      ),

                      const SizedBox(width: 50),

                      // Lado direito: Repositórios e Organizações
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Repositórios',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _repositories.length,
                                itemBuilder: (context, index) {
                                  final repo = _repositories[index];
                                  return RepositoryTile(
                                    repository: repo,
                                    githubService: widget.githubService,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Organizações',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _organizations.length,
                                itemBuilder: (context, index) {
                                  final org = _organizations[index];
                                  return LyListTile(
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(org.avatarUrl),
                                    ),
                                    title: Text(org.login),
                                    subtitle: Text(org.description),
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              OrganizationPage(
                                            organizationName: org.login,
                                            githubService: widget.githubService,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
      ),
    );
  }
}
