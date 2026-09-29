import 'package:flutter_test/flutter_test.dart';

import 'package:livekit_client/livekit_client.dart';

import 'package:livekit_components/livekit_components.dart';

void main() {
  group('RoomContext.connect', () {
    test('rethrows the original error and calls onError when the failure is not a LiveKitException', () async {
      var onErrorCalls = 0;
      final context = RoomContext(onError: (LiveKitException? error) => onErrorCalls++);
      addTearDown(context.dispose);

      // No url or token was given, so connect fails before reaching the server with a
      // non-LiveKitException error.
      Object? thrown;
      try {
        await context.connect();
      } catch (e) {
        thrown = e;
      }

      expect(thrown, isNotNull);
      expect(thrown.toString(), isNot(contains('is not a subtype')));
      expect(onErrorCalls, 1);
      expect(context.connecting, isFalse);
    });
  });
}
