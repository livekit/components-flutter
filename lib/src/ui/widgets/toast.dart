// Copyright 2024 LiveKit, Inc.
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

import 'dart:async';

import 'package:flutter/material.dart' hide ConnectionState;

import 'package:livekit_client/livekit_client.dart';
import 'package:provider/provider.dart';

import '../../context/room_context.dart';

class ToastWidget extends StatefulWidget {
  const ToastWidget({
    super.key,
    this.duration = const Duration(seconds: 2),
    this.fadeDuration = const Duration(milliseconds: 350),
    this.onDismiss,
    this.ignorePointer = false,
  });

  final bool ignorePointer;
  final VoidCallback? onDismiss;
  final Duration duration;
  final Duration fadeDuration;

  @override
  ToastState createState() => ToastState();
}

class ToastState extends State<ToastWidget> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  late Animation _fadeAnimation;
  Timer? _timer;

  ConnectionState _connectionState = ConnectionState.disconnected;

  showIt() {
    _animationController!.forward();
  }

  hideIt() {
    _animationController!.reverse();
    _timer?.cancel();
    _timer = null;
  }

  void showToast() {
    showIt();
    _timer = Timer(widget.duration, () {
      hideIt();
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController!, curve: Curves.easeIn);
    super.initState();
  }

  @override
  void deactivate() {
    _timer?.cancel();
    _animationController!.stop();
    super.deactivate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomContext>(
      builder: (context, roomCtx, child) => Selector<RoomContext, ConnectionState>(
        selector: (context, connectionState) => roomCtx.connectionState,
        builder: (context, connectionState, child) {
          if (connectionState != _connectionState) {
            _connectionState = roomCtx.connectionState;
            showToast();
          }
          return GestureDetector(
            onTap: widget.onDismiss == null ? null : () => widget.onDismiss!(),
            behavior: HitTestBehavior.translucent,
            child: IgnorePointer(
              ignoring: widget.ignorePointer,
              child: FadeTransition(
                opacity: _fadeAnimation as Animation<double>,
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: toast(_connectionState),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget toast(ConnectionState state) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: {
              ConnectionState.connected: Colors.green,
              ConnectionState.disconnected: Colors.grey,
              ConnectionState.connecting: Colors.grey,
              ConnectionState.reconnecting: Colors.orangeAccent,
            }[state]),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
                {
                  ConnectionState.connected: Icons.check,
                  ConnectionState.disconnected: Icons.close,
                  ConnectionState.connecting: Icons.hourglass_top,
                  ConnectionState.reconnecting: Icons.refresh,
                }[state],
                color: Colors.white),
            const SizedBox(width: 12.0),
            Text(
              '${{
                ConnectionState.connected: 'Connected',
                ConnectionState.disconnected: 'Disconnected',
                ConnectionState.connecting: 'Connecting',
                ConnectionState.reconnecting: 'Reconnecting',
              }[state]}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
}
