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

class CameraSwitchButton extends StatelessWidget {
  const CameraSwitchButton({
    super.key,
    this.currentPosition = CameraPosition.front,
    this.onToggle,
    this.disabled = false,
    this.backgroundColor = Colors.grey,
    this.foregroundColor = Colors.white,
    this.overlayColor = Colors.grey,
  });

  final CameraPosition? currentPosition;
  final Function(CameraPosition position)? onToggle;
  final bool disabled;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color overlayColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor:
            WidgetStateProperty.all(backgroundColor.withValues(alpha: 0.9)),
        foregroundColor: WidgetStateProperty.all(foregroundColor),
        overlayColor: WidgetStateProperty.all(overlayColor),
        shape: WidgetStateProperty.all(const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)))),
        padding: WidgetStateProperty.all(
          const EdgeInsets.all(12),
        ),
      ),
      onPressed: () => onToggle?.call(currentPosition == CameraPosition.front
          ? CameraPosition.back
          : CameraPosition.front),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(currentPosition == CameraPosition.back
              ? Icons.video_camera_back
              : Icons.video_camera_front),
        ],
      ),
    );
  }
}
