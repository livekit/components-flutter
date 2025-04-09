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

import '../../../context/media_device_context.dart';
import '../../../context/room_context.dart';
import '../theme.dart';

class ScreenShareToggleWidget extends StatelessWidget {
  const ScreenShareToggleWidget({
    super.key,
    required this.roomCtx,
    required this.deviceCtx,
    required this.screenShareEnabled,
    this.showLabel = false,
    this.backgroundColor = Colors.grey,
    this.foregroundColor = Colors.white,
    this.selectedColor = LKColors.lkBlue,
    this.overlayColor = Colors.grey,
    this.selectedOverlayColor = LKColors.lkLightBlue,
  });

  final bool screenShareEnabled;
  final bool showLabel;
  final RoomContext roomCtx;
  final MediaDeviceContext deviceCtx;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color overlayColor;
  final Color selectedColor;
  final Color selectedOverlayColor;

  @override
  Widget build(BuildContext context) {
    var deviceScreenType = getDeviceType(MediaQuery.of(context).size);
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(screenShareEnabled
            ? selectedColor
            : backgroundColor.withValues(alpha: 0.9)),
        foregroundColor: WidgetStateProperty.all(foregroundColor),
        overlayColor: WidgetStateProperty.all(
            screenShareEnabled ? selectedOverlayColor : overlayColor),
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
      onPressed: () => screenShareEnabled
          ? deviceCtx.disableScreenShare()
          : deviceCtx.enableScreenShare(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(screenShareEnabled
              ? Icons.stop_screen_share_outlined
              : Icons.screen_share_outlined),
          const SizedBox(width: 2),
          if (deviceScreenType != DeviceScreenType.mobile || showLabel)
            Text(
              screenShareEnabled ? 'Stop screen share ' : 'Screen share',
              style: const TextStyle(fontSize: 14),
            ),
        ],
      ),
    );
  }
}
