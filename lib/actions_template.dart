import 'package:autoflow/models/repository_model.dart';

enum ActionTrigger {
  onPush,
  onDispatch,
}

class ActionsTemplate {
  static String onPush(String branch) {
    return '''
on:
  push:
    branches:
      - $branch
''';
  }

  static String onDispatch(String branch) {
    return '''
on:
  workflow_dispatch:
    inputs:
      branch_name:
        description: $branch
        required: true
''';
  }

  static String workflowName(String name) {
    return '''
name: $name
''';
  }

  static String envs({String? propertiesPath, String? keyPath}) {
    if (propertiesPath == null || keyPath == null) {
      return '';
    }
    return '''
env:
  PROPERTIES_PATH: "$propertiesPath"
  KEY_PATH: "$keyPath"
''';
  }

  static String checkoutCodeStep() {
    return '''
- name: Checkout code
        uses: actions/checkout@v4
''';
  }

  static String extractVersionStep() {
    return '''
- name: Extract Version
        id: extract_version
        run: |
          version=\$(grep -m 1 '^version: ' pubspec.yaml | awk '{print \$2}' | awk -F'+' '{print \$1}')
          echo "version=\$version" >> \$GITHUB_ENV
          echo "version=\$version" >> \$GITHUB_OUTPUT
''';
  }

  static String setupJavaStep() {
    return '''
- name: Set up Java
        uses: actions/setup-java@v4
        with:
          distribution: "zulu"
          java-version: "17.x"
''';
  }

  static String cacheGradleDependenciesStep() {
    return '''
- name: Cache Gradle dependencies
        uses: actions/cache@v4
        with:
          path: |
            ~/.gradle/caches
            ~/.gradle/wrapper
          key: \${{ runner.os }}-gradle-\${{ hashFiles('**/*.gradle*') }}
          restore-keys: |
            \${{ runner.os }}-gradle-
''';
  }

  static String setupFlutterStep(String flutterVersion) {
    return '''
- name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: "stable"
          ${flutterVersion.isNotEmpty ? 'flutter-version: $flutterVersion' : ''}
''';
  }

  static String createKeyPropertiesStep({bool show = true}) {
    if (!show) {
      return '';
    }
    return '''
- name: Create key.properties
        run: echo "\${{ secrets.KEY_PROPERTIES_BASE64 }}" | base64 --decode > \${{env.PROPERTIES_PATH}}
''';
  }

  static String createKeyJksStep({bool show = true}) {
    if (!show) {
      return '';
    }
    return '''
- name: Create key.jks
        run: echo "\${{ secrets.KEY_STORE_BASE64 }}" | base64 --decode > \${{env.KEY_PATH}}
''';
  }

  static String getFlutterDependenciesStep() {
    return '''
- name: Get Flutter dependencies
        run: flutter pub get
''';
  }

  static String buildUniversalApkStep() {
    return '''
- name: Build universal APK
        run: flutter build apk --release
''';
  }

  static String releaseUniversalApkStep(
      String owner, String repo, String branch) {
    return '''
- name: Release universal APK
        uses: svenstaro/upload-release-action@v2
        with:
          repo_name: $owner/$repo
          repo_token: \${{ secrets.GITHUB_TOKEN }}
          file: build/app/outputs/flutter-apk/app-release.apk
          asset_name: $repo-\${{steps.extract_version.outputs.version}}.apk
          target_commit: $branch
          tag: \${{steps.extract_version.outputs.version}}
          prerelease: false
          overwrite: true
''';
  }

  static String jobs({
    required RepositoryModel repo,
    required String branch,
    String flutterVersion = '',
    bool signApp = false,
  }) {
    return '''
jobs:
  build:
    name: Build APK
    runs-on: ubuntu-latest

    steps:
      ${checkoutCodeStep()}
      ${extractVersionStep()}
      ${setupJavaStep()}
      ${cacheGradleDependenciesStep()}
      ${setupFlutterStep(flutterVersion)}
      ${createKeyPropertiesStep(show: signApp)}
      ${createKeyJksStep(show: signApp)}
      ${getFlutterDependenciesStep()}
      ${buildUniversalApkStep()}
      ${releaseUniversalApkStep(repo.login, repo.name, branch)}
''';
  }

  static String generateWorkflow({
    required RepositoryModel repo,
    required String workflowName,
    String? propertiesPath,
    String? keyPath,
    ActionTrigger trigger = ActionTrigger.onDispatch,
    String flutterVersion = '',
    String branch = 'main',
    bool signApp = false,
  }) {
    return '''
${() {
      switch (trigger) {
        case ActionTrigger.onPush:
          return ActionsTemplate.onPush(branch);
        case ActionTrigger.onDispatch:
          return ActionsTemplate.onDispatch(branch);
      }
    }()}
${ActionsTemplate.workflowName(workflowName)}
${ActionsTemplate.envs(
      propertiesPath: propertiesPath,
      keyPath: keyPath,
    )}
${ActionsTemplate.jobs(
      repo: repo,
      flutterVersion: flutterVersion,
      signApp: signApp,
      branch: branch,
    )}
'''
        .trim();
  }
}
