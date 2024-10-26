import 'package:autoflow/models/action_model.dart';
import 'package:autoflow/models/repository_model.dart';
import 'package:autoflow/pages/action_logs_page.dart';
import 'package:autoflow/pages/workflow_creator.dart';
import 'package:autoflow/services/github_service.dart';
import 'package:autoflow/ui/lists/ly_list_tile.dart';
import 'package:flutter/material.dart';

class RepositoryActionsPage extends StatefulWidget {
  final String owner;
  final RepositoryModel repo;
  final GithubService githubService;

  const RepositoryActionsPage({
    super.key,
    required this.owner,
    required this.repo,
    required this.githubService,
  });

  @override
  State<RepositoryActionsPage> createState() => _RepositoryActionsPageState();
}

class _RepositoryActionsPageState extends State<RepositoryActionsPage> {
  bool _loading = true;
  List<ActionModel>? _actions;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadActions();
  }

  Future<void> _loadActions() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final actions = await widget.githubService.loadRepositoryActions(
        widget.owner,
        widget.repo.name,
      );
      setState(() {
        _actions = actions;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar ações: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _invokeAction(ActionModel action) async {
    await widget.githubService.invokeAction(
      widget.owner,
      widget.repo.name,
      action.id,
      action.branch,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ação ${action.name} invocada com sucesso!')),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActionsRunsPage(
          owner: widget.owner,
          repo: widget.repo.name,
          githubService: widget.githubService,
          action: action,
        ),
      ),
    );

    // Recarregar as ações após o Navigator concluir
    await _loadActions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkflowCreator(
                githubService: widget.githubService,
                repo: widget.repo,
              ),
            ),
          );
          _loadActions();
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text('Ações - ${widget.repo.name}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!),
                )
              : _actions != null && _actions!.isNotEmpty
                  ? ListView.builder(
                      itemCount: _actions!.length,
                      itemBuilder: (context, index) {
                        final action = _actions![index];
                        return LyListTile(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ActionsRunsPage(
                                owner: widget.owner,
                                repo: widget.repo.name,
                                githubService: widget.githubService,
                                action: action,
                              ),
                            ));
                          },
                          title: Text(action.name),
                          trailing: IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: () {
                              _invokeAction(action);
                            },
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text('Nenhuma ação encontrada.'),
                    ),
    );
  }
}
