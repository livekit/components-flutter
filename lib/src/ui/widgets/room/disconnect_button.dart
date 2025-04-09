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

import 'package:flutter/material.dart';

import 'package:livekit_client/livekit_client.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../context/room_context.dart';

class DisconnectButtonWidget extends StatelessWidget {
  const DisconnectButtonWidget({
    super.key,
    required this.roomCtx,
    required this.connected,
    this.onPressed,
    this.title = 'Leave',
    this.showLabel = true,
    this.backgroundColor = Colors.grey,
    this.selectedColor = Colors.red,
    this.foregroundColor = Colors.white,
    this.overlayColor = Colors.grey,
    this.selectedOverlayColor = Colors.redAccent,
  });

  final bool connected;
  final RoomContext roomCtx;
  final String title;
  final bool showLabel;

  final Color backgroundColor;
  final Color foregroundColor;
  final Color overlayColor;
  final Color selectedColor;
  final Color selectedOverlayColor;

  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    var deviceScreenType = getDeviceType(MediaQuery.of(context).size);
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
            connected ? selectedColor : backgroundColor.withValues(alpha: 0.9)),
        foregroundColor: WidgetStateProperty.all(foregroundColor),
        overlayColor: WidgetStateProperty.all(
            connected ? selectedOverlayColor : overlayColor),
        shape: WidgetStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
          ),
        ),
        padding: WidgetStateProperty.all(
          (lkPlatformIsMobile() || lkPlatformIsWebMobile())
              ? const EdgeInsets.all(12)
              : const EdgeInsets.fromLTRB(12, 20, 12, 20),
        ),
      ),
      onPressed: () =>
          onPressed?.call() ?? connected ? roomCtx.disconnect() : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.logout),
          const SizedBox(width: 2),
          if (deviceScreenType != DeviceScreenType.mobile || showLabel)
            Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
        ],
      ),
    );
  }
}
