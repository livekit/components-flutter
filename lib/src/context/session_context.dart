// Copyright 2025 LiveKit, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/widgets.dart';

import 'package:livekit_client/livekit_client.dart';

/// Provides a [Session] to descendant widgets.
///
/// Use this to make a single `Session` visible to session-aware widgets (for
/// example, `ChatScrollView`) without passing it through every constructor.
/// Because it inherits from [InheritedNotifier], it will rebuild dependents
/// when the session notifies listeners, but you can safely use [maybeOf] if
/// you are in an optional context.
class SessionScope extends InheritedNotifier<Session> {
  const SessionScope({
    super.key,
    required Session session,
    required super.child,
  }) : super(notifier: session);

  /// Returns the nearest [Session] in the widget tree or `null` if none exists.
  static Session? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SessionScope>()?.notifier;
  }

  /// Returns the nearest [Session] in the widget tree.
  /// Throws a [FlutterError] if no session is found.
  static Session of(BuildContext context) {
    final session = maybeOf(context);
    if (session == null) {
      throw FlutterError(
        'SessionScope.of() called with no Session in the context. '
        'Add a SessionScope above this widget or pass a Session directly.',
      );
    }
    return session;
  }
}
