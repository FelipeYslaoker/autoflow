import 'dart:convert';
import 'package:autoflow/actions_template.dart';
import 'package:autoflow/models/repository_model.dart';
import 'package:autoflow/services/github_service.dart';
import 'package:autoflow/ui/buttons/ly_filled_button.dart';
import 'package:autoflow/ui/lists/ly_list_tile.dart';
import 'package:autoflow/ui/text_fields/ly_text_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class WorkflowCreator extends StatefulWidget {
  final GithubService githubService;
  final RepositoryModel repo;
  const WorkflowCreator({
    super.key,
    required this.githubService,
    required this.repo,
  });

  @override
  State<WorkflowCreator> createState() => _WorkflowCreatorState();
}

class _WorkflowCreatorState extends State<WorkflowCreator> {
  File? _keyPropertiesFile;
  File? _keyJksFile;
  File? _serviceAccountJsonFile;

  final _keyPropertiesController = TextEditingController(
    text: './android/key.properties',
  );
  final _keyJksController = TextEditingController(
    text: './android/app/key.jks',
  );
  final _flutterVersionController = TextEditingController();
  final _workflowNameController = TextEditingController();
  final _workflowDescriptionController = TextEditingController();
  final _branchController = TextEditingController(text: 'main');

  bool _loading = false; // Variável de loading

  @override
  void dispose() {
    _keyPropertiesController.dispose();
    _keyJksController.dispose();
    _flutterVersionController.dispose();
    _workflowNameController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        if (type == 'key.properties') {
          _keyPropertiesFile = File(result.files.single.path!);
        } else if (type == 'key.jks') {
          _keyJksFile = File(result.files.single.path!);
        } else if (type == 'serviceAccountJson') {
          _serviceAccountJsonFile = File(result.files.single.path!);
        }
      });
    }
  }

  Future<void> _saveWorkflow() async {
    setState(() {
      _loading = true; // Ativa loading
    });

    try {
      if (_keyPropertiesFile != null) {
        final keyPropertiesBase64 =
            base64Encode(_keyPropertiesFile!.readAsBytesSync());
        await widget.githubService.createEncryptedSecret(
          'KEY_PROPERTIES_BASE64',
          keyPropertiesBase64,
          widget.repo,
        );
      }

      if (_keyJksFile != null) {
        final keyJksBase64 = base64Encode(_keyJksFile!.readAsBytesSync());
        await widget.githubService.createEncryptedSecret(
          'KEY_STORE_BASE64',
          keyJksBase64,
          widget.repo,
        );
      }

      if (_serviceAccountJsonFile != null) {
        final serviceAccountJsonBase64 =
            base64Encode(_serviceAccountJsonFile!.readAsBytesSync());
        await widget.githubService.createEncryptedSecret(
          'SERVICE_ACCOUNT_JSON_BASE64',
          serviceAccountJsonBase64,
          widget.repo,
        );
      }

      print('Flutter Version: ${_flutterVersionController.text}');
      print('Workflow Name: ${_workflowNameController.text}');
      await widget.githubService.commitFileToRepo(
        repo: widget.repo,
        content: ActionsTemplate.generateWorkflow(
          repo: widget.repo,
          workflowName: _workflowDescriptionController.text.trim(),
          branch: _branchController.text,
          flutterVersion: _flutterVersionController.text.trim(),
          keyPath: _keyJksController.text,
          propertiesPath: _keyPropertiesController.text,
          signApp: _keyPropertiesFile != null && _keyJksFile != null,
          trigger: ActionTrigger.onDispatch,
        ),
        fileDirectory:
            '.github/workflows/autoflow.${_workflowNameController.text}.yml',
        commitMessage: 'Autoflow Update',
        branch: _branchController.text,
      );
      Navigator.pop(context);
    } catch (e) {
      print('Erro ao salvar o workflow: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workflow Editor'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LyTextField(
            controller: _branchController,
            labelText: 'Branch',
            hintText: 'Ex: main',
            enabled: !_loading,
          ),
          const SizedBox(height: 12),
          LyTextField(
            controller: _workflowNameController,
            labelText: 'Nome do workflow',
            hintText: 'Ex: test, release',
            enabled: !_loading,
          ),
          const SizedBox(height: 12),
          LyTextField(
            controller: _workflowDescriptionController,
            labelText: 'Descrição do workflow',
            hintText: 'Ex: Test, Build and Release apk',
            enabled: !_loading,
          ),
          const SizedBox(height: 24),
          // Anexar key.properties
          LyListTile(
            enabled: !_loading,
            onTap: () {
              _pickFile('key.properties');
            },
            title: const Text('Anexar key.properties'),
            subtitle: Text(_keyPropertiesFile != null
                ? _keyPropertiesFile!.path
                : 'Nenhum arquivo anexado'),
            trailing: IgnorePointer(
              child: IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: () {},
              ),
            ),
          ),

          // Anexar key.jks
          LyListTile(
            enabled: !_loading,
            onTap: () {
              _pickFile('key.jks');
            },
            title: const Text('Anexar key.jks'),
            subtitle: Text(_keyJksFile != null
                ? _keyJksFile!.path
                : 'Nenhum arquivo anexado'),
            trailing: IgnorePointer(
              child: IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: () {},
              ),
            ),
          ),

          LyListTile(
            enabled: !_loading,
            onTap: () {
              _pickFile('serviceAccountJson');
            },
            title: const Text('Anexar serviceAccountJson'),
            subtitle: Text(_serviceAccountJsonFile != null
                ? _serviceAccountJsonFile!.path
                : 'Nenhum arquivo anexado'),
            trailing: IgnorePointer(
              child: IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: () {},
              ),
            ),
          ),

          const SizedBox(height: 24),

          LyTextField(
            controller: _keyPropertiesController,
            labelText: 'Caminho de key.properties',
            enabled: !_loading,
          ),

          const SizedBox(height: 24),

          LyTextField(
            controller: _keyJksController,
            labelText: 'Caminho de key.jks',
            enabled: !_loading,
          ),

          const SizedBox(height: 24),

          LyTextField(
            controller: _flutterVersionController,
            labelText: 'Versão do Flutter (Última por padrão)',
            enabled: !_loading,
          ),

          const SizedBox(height: 24),

          Center(
            child: LyFilledButton(
              onPressed: _saveWorkflow,
              loading: _loading,
              child: const Text('Salvar'),
            ),
          )
        ],
      ),
    );
  }
}
