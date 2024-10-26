import 'dart:convert';

import 'package:autoflow/models/action_model.dart';
import 'package:autoflow/models/actions_run_model.dart';
import 'package:autoflow/models/organization_model.dart';
import 'package:autoflow/models/repository_model.dart';
import 'package:autoflow/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sodium_libs/sodium_libs.dart';

class GithubService {
  Dio _dio = Dio();

  late final Sodium sodium;

  GithubService({
    required String? personalAccessToken,
  }) {
    if (personalAccessToken != null && personalAccessToken.isNotEmpty) {
      _saveToken(personalAccessToken);
    }
  }

  String? accessToken;
  final storage = const FlutterSecureStorage();
  bool _loggedIn = false;

  bool get loggedIn => _loggedIn;

  Future<void> initialize() async {
    await _loadTokenFromStorage();
    sodium = await SodiumInit.init();

    if (accessToken != null) {
      _dio = Dio(
        BaseOptions(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
    }
  }

  Future<void> _saveToken(String token) async {
    await storage.write(
      key: 'personal_access_token',
      value: token,
    );
    accessToken = token;
    _loggedIn = true;

    _dio = Dio(
      BaseOptions(
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );
  }

  Future<void> _loadTokenFromStorage() async {
    final token = await storage.read(key: 'personal_access_token');
    if (token != null && token.isNotEmpty) {
      accessToken = token;
      _loggedIn = true;
    } else {
      _loggedIn = false;
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'personal_access_token');
    _loggedIn = false;
    accessToken = null;

    _dio = Dio(BaseOptions());
  }

  Future<UserModel?> getUser() async {
    if (!loggedIn || accessToken == null) {
      throw Exception(
          'Usuário não está logado ou token de acesso está ausente.');
    }

    try {
      final response = await _dio.get('https://api.github.com/user');
      return UserModel.fromMap(response.data);
    } catch (e) {
      throw Exception('Erro ao buscar dados do usuário: $e');
    }
  }

  Future<List<RepositoryModel>> getUserRepositories() async {
    try {
      final response = await _dio.get('https://api.github.com/user/repos');
      return (response.data as List)
          .map((repo) => RepositoryModel.fromMap(repo))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar repositórios: $e');
    }
  }

  Future<List<OrganizationModel>> getUserOrganizations() async {
    try {
      final response = await _dio.get('https://api.github.com/user/orgs');
      return (response.data as List)
          .map((org) => OrganizationModel.fromMap(org))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar organizações: $e');
    }
  }

  Future<List<RepositoryModel>> getOrganizationRepositories(
      String orgName) async {
    try {
      final response =
          await _dio.get('https://api.github.com/orgs/$orgName/repos');
      return (response.data as List)
          .map((repo) => RepositoryModel.fromMap(repo))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar repositórios da organização: $e');
    }
  }

  Future<List<ActionModel>> loadRepositoryActions(
      String owner, String repo) async {
    final url = 'https://api.github.com/repos/$owner/$repo/actions/workflows';
    print('$url, $accessToken');
    final response = await _dio.get(
      url,
    );
    print(response.data.toString());

    final workflows = response.data['workflows'] as List;
    return workflows.map((workflow) => ActionModel.fromJson(workflow)).toList();
  }

  Future<void> invokeAction(
    String owner,
    String repo,
    String workflowId,
    String branch,
  ) async {
    try {
      final url =
          'https://api.github.com/repos/$owner/$repo/actions/workflows/$workflowId/dispatches';
      final data = {
        "ref": branch,
        "inputs": {
          "branch_name": branch,
        },
      };

      await _dio.post(
        url,
        data: data,
      );
    } on DioException catch (e) {
      print('Erro ao disparar evento: ${e.response?.data}');
    }
  }

  Future<List<ActionsRunModel>> getActionRuns(
      String owner, String repo, String workflowId) async {
    try {
      final response = await _dio.get(
          'https://api.github.com/repos/$owner/$repo/actions/workflows/$workflowId/runs');
      final List<dynamic> logsJson = response.data['workflow_runs'];
      return logsJson.map((json) => ActionsRunModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load actions logs: $e');
    }
  }

  Future<void> createEncryptedSecret(
    String key,
    String value,
    RepositoryModel repo,
  ) async {
    try {
      final publicKeyResponse = await _dio.get(
        'https://api.github.com/repos/${repo.login}/${repo.name}/actions/secrets/public-key',
      );
      final publicKeyData = publicKeyResponse.data;
      final repoPublicKey = publicKeyData['key'];
      final keyId = publicKeyData['key_id'];

      final publicKeyBytes = base64Decode(repoPublicKey);
      final valueBytes = utf8.encode(value);
      final encryptedValue = sodium.crypto.box.seal(
        message: valueBytes,
        publicKey: publicKeyBytes,
      );

      final encryptedValueBase64 = base64Encode(encryptedValue);

      final secretData = {
        'encrypted_value': encryptedValueBase64,
        'key_id': keyId,
      };

      await _dio.put(
        'https://api.github.com/repos/${repo.login}/${repo.name}/actions/secrets/$key',
        data: jsonEncode(secretData),
      );

      print('Secret "$key" criada com sucesso no repositório ${repo.name}.');
    } catch (e) {
      throw Exception('Erro ao criar a secret: $e');
    }
  }

  Future<void> commitFileToRepo({
    required RepositoryModel repo,
    required String content,
    required String fileDirectory,
    required String commitMessage,
    String branch = 'main',
  }) async {
    final url =
        'https://api.github.com/repos/${repo.login}/${repo.name}/contents/$fileDirectory';

    try {
      String base64Content = base64Encode(utf8.encode(content));

      Response fileResponse;
      String? fileSha;

      try {
        fileResponse = await _dio.get(url, queryParameters: {'ref': branch});
        fileSha = fileResponse.data['sha'];
      } catch (e) {
        fileSha = null;
      }

      await _dio.put(
        url,
        data: {
          'message': commitMessage,
          'content': base64Content,
          'branch': branch,
          if (fileSha != null) 'sha': fileSha,
        },
      );

      print('Arquivo commitado com sucesso!');
    } on DioException catch (e) {
      print('Erro ao commitar arquivo: ${e.response?.data}');
    }
  }
}
