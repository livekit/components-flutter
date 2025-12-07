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

import 'package:flutter/material.dart';

import 'package:livekit_client/livekit_client.dart';

import '../../context/session_context.dart';

/// A scrollable list that renders [Session.messages] with newest messages at
/// the bottom and auto-scrolls when new messages arrive.
///
/// Provide a [Session] via [session] or a surrounding [SessionContext]. Use
/// [messageBuilder] to render each [ReceivedMessage]; the builder runs in
/// reverse order so index `0` corresponds to the latest message.
class ChatScrollView extends StatefulWidget {
  const ChatScrollView({
    super.key,
    required this.messageBuilder,
    this.session,
    this.autoScroll = true,
    this.scrollController,
    this.padding,
    this.physics,
  });

  /// Optional session instance. If omitted, [SessionContext.of] is used.
  final Session? session;

  /// Builder for each message.
  final Widget Function(BuildContext context, ReceivedMessage message) messageBuilder;

  /// Whether the list should automatically scroll to the latest message when
  /// the message count changes.
  final bool autoScroll;

  /// Optional scroll controller. If not provided, an internal controller is
  /// created and disposed automatically.
  final ScrollController? scrollController;

  /// Optional padding applied to the list.
  final EdgeInsetsGeometry? padding;

  /// Optional scroll physics.
  final ScrollPhysics? physics;

  @override
  State<ChatScrollView> createState() => _ChatScrollViewState();
}

class _ChatScrollViewState extends State<ChatScrollView> {
  ScrollController? _internalController;
  int _lastMessageCount = 0;

  ScrollController get _controller => widget.scrollController ?? _internalController!;

  @override
  void initState() {
    super.initState();
    _internalController = widget.scrollController ?? ScrollController();
  }

  @override
  void didUpdateWidget(ChatScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      _internalController?.dispose();
      _internalController = widget.scrollController ?? ScrollController();
    }
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _internalController?.dispose();
    }
    super.dispose();
  }

  Session _resolveSession(BuildContext context) {
    return widget.session ?? SessionContext.of(context);
  }

  void _autoScrollIfNeeded(List<ReceivedMessage> messages) {
    if (!widget.autoScroll) {
      _lastMessageCount = messages.length;
      return;
    }
    if (messages.length == _lastMessageCount) {
      return;
    }
    _lastMessageCount = messages.length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasClients) {
        return;
      }
      _controller.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = _resolveSession(context);

    return AnimatedBuilder(
      animation: session,
      builder: (context, _) {
        final messages = [...session.messages]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
        _autoScrollIfNeeded(messages);

        return ListView.builder(
          reverse: true,
          controller: _controller,
          padding: widget.padding,
          physics: widget.physics,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[messages.length - 1 - index];
            return widget.messageBuilder(context, message);
          },
        );
      },
    );
  }
}
