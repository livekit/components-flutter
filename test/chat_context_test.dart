import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:livekit_client/livekit_client.dart';

import 'package:livekit_components/src/context/chat_context.dart';

class _ChatContext extends ChangeNotifier with ChatContextMixin {}

DataReceivedEvent _chatEvent(String message) => DataReceivedEvent(
      participant: null,
      data: utf8.encode(jsonEncode({'message': message, 'timestamp': 1, 'id': message})),
      topic: 'lk-chat-topic',
    );

void main() {
  group('ChatContextMixin', () {
    test('adds each received message once', () async {
      final room = Room();
      final chat = _ChatContext()..chatContextSetup(room.createListener(), null);

      // ignore: invalid_use_of_internal_member
      room.events.emit(_chatEvent('hello'));
      await Future<void>.delayed(Duration.zero);

      expect(chat.messages.map((m) => m.message), ['hello']);
      await room.dispose();
    });

    test('adds each message once after a disconnect and reconnect', () async {
      final room = Room();
      final listener = room.createListener();
      final chat = _ChatContext();

      // RoomContext runs this sequence on RoomConnectedEvent, RoomDisconnectedEvent and the next
      // RoomConnectedEvent, all with the same room listener.
      chat.chatContextSetup(listener, null);
      chat.chatContextSetup(null, null);
      chat.chatContextSetup(listener, null);

      // ignore: invalid_use_of_internal_member
      room.events.emit(_chatEvent('hello'));
      await Future<void>.delayed(Duration.zero);

      expect(chat.messages.map((m) => m.message), ['hello']);
      await room.dispose();
    });

    test('stops receiving messages after the disconnect cleanup', () async {
      final room = Room();
      final chat = _ChatContext()..chatContextSetup(room.createListener(), null);
      chat.chatContextSetup(null, null);

      // ignore: invalid_use_of_internal_member
      room.events.emit(_chatEvent('late'));
      await Future<void>.delayed(Duration.zero);

      expect(chat.messages, isEmpty);
      await room.dispose();
    });
  });
}
