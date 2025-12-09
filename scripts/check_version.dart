#!/usr/bin/env dart
/*
 * Copyright 2025 LiveKit
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:io';

class _Path {
  static const pubspec = 'pubspec.yaml';
  static const changelog = 'CHANGELOG.md';
  static const version = '.version';
  static const flutterSdkPubspec = '../client-sdk-flutter/pubspec.yaml';
}

class _Color {
  static const reset = '\x1B[0m';
  static const green = '\x1B[32m';
  static const bold = '\x1B[1m';
}

String readFile(String path) {
  try {
    return File(path).readAsStringSync();
  } catch (e) {
    throw Exception('Failed to read $path: $e');
  }
}

String normalizeValue(String raw) {
  var result = raw.trim();

  if (result.startsWith('#')) {
    result = '';
  }

  if (result.contains('#')) {
    result = result.split('#').first.trim();
  }

  if ((result.startsWith('"') && result.endsWith('"')) || (result.startsWith("'") && result.endsWith("'"))) {
    result = result.substring(1, result.length - 1);
  }

  return result;
}

String extractPubspecVersion(String content) {
  final match = RegExp(r'^version:\s+(.+)$', multiLine: true).firstMatch(content);
  if (match == null) {
    throw Exception('Could not find version in ${_Path.pubspec}');
  }

  final versionStr = normalizeValue(match.group(1)!);
  if (versionStr.isEmpty) {
    throw Exception('Empty version in ${_Path.pubspec}');
  }

  return versionStr;
}

String extractChangelogVersion(String content) {
  final match = RegExp(r'^##\s+([^\s(]+)', multiLine: true).firstMatch(content);
  if (match == null) {
    throw Exception('Could not find version entry in ${_Path.changelog}');
  }

  return match.group(1)!;
}

String extractDependencyVersion(
  String content,
  String dependencyName, {
  required String sourceName,
}) {
  final pattern = RegExp('^\\s*$dependencyName:\\s*([^\\n#]+)', multiLine: true);
  final match = pattern.firstMatch(content);
  if (match == null) {
    throw Exception('Could not find $dependencyName in $sourceName');
  }

  final version = normalizeValue(match.group(1)!);
  if (version.isEmpty) {
    throw Exception('Empty version for $dependencyName in $sourceName');
  }

  return version;
}

void checkVersionConsistency(String expectedVersion) {
  final versionFile = readFile(_Path.version).trim();
  if (versionFile != expectedVersion) {
    throw Exception('Version mismatch in ${_Path.version}: expected $expectedVersion, found $versionFile');
  }

  final changelogVersion = extractChangelogVersion(readFile(_Path.changelog));
  if (changelogVersion != expectedVersion) {
    throw Exception(
      'Version mismatch in ${_Path.changelog}: expected $expectedVersion, found $changelogVersion',
    );
  }
}

void checkFlutterWebRtcVersion() {
  final componentsPubspec = readFile(_Path.pubspec);
  final flutterSdkPubspec = readFile(_Path.flutterSdkPubspec);

  final componentsWebRtc = extractDependencyVersion(
    componentsPubspec,
    'flutter_webrtc',
    sourceName: _Path.pubspec,
  );
  final sdkWebRtcVersion = extractDependencyVersion(
    flutterSdkPubspec,
    'flutter_webrtc',
    sourceName: _Path.flutterSdkPubspec,
  );

  if (componentsWebRtc != sdkWebRtcVersion) {
    throw Exception(
      'flutter_webrtc version mismatch: components=$componentsWebRtc, Flutter SDK=$sdkWebRtcVersion',
    );
  }

  print('${_Color.green}flutter_webrtc version matches Flutter SDK: $componentsWebRtc${_Color.reset}');
}

void main() {
  try {
    final pubspecContent = readFile(_Path.pubspec);
    final version = extractPubspecVersion(pubspecContent);
    print('Checking version ${_Color.bold}${_Color.green}$version${_Color.reset}');

    checkVersionConsistency(version);
    checkFlutterWebRtcVersion();

    print('${_Color.bold}${_Color.green}All version checks passed ✓${_Color.reset}');
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}
