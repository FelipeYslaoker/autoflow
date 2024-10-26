import 'dart:async';
import 'package:autoflow/models/action_model.dart';
import 'package:autoflow/ui/lists/ly_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:autoflow/services/github_service.dart';
import 'package:autoflow/models/actions_run_model.dart';

class ActionsRunsPage extends StatefulWidget {
  final String owner;
  final String repo;
  final GithubService githubService;
  final ActionModel action;

  const ActionsRunsPage({
    super.key,
    required this.owner,
    required this.repo,
    required this.githubService,
    required this.action,
  });

  @override
  _ActionsRunsPageState createState() => _ActionsRunsPageState();
}

class _ActionsRunsPageState extends State<ActionsRunsPage> {
  late Future<List<ActionsRunModel>> _actionsLogFuture;

  @override
  void initState() {
    super.initState();
    _loadActionsLogs();
    // Start polling every 60 seconds
    _loadActionsLogs();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadActionsLogs() {
    setState(() {
      _actionsLogFuture = widget.githubService.getActionRuns(
        widget.owner,
        widget.repo,
        widget.action.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actions Logs for ${widget.repo}'),
      ),
      body: FutureBuilder<List<ActionsRunModel>>(
        future: _actionsLogFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final actionsLogs = snapshot.data!;
            return ListView.builder(
              itemCount: actionsLogs.length,
              itemBuilder: (context, index) {
                final log = actionsLogs[index];
                return LyListTile(
                  title: Text(log.name),
                  subtitle: Text(
                      'Status: ${log.status} - Conclusion: ${log.conclusion}'),
                  trailing: Text('Updated: ${log.updatedAt}'),
                  onTap: () {
                    // Handle tap if you want to show more details
                  },
                );
              },
            );
          } else {
            return const Center(child: Text('No actions logs found.'));
          }
        },
      ),
    );
  }
}
