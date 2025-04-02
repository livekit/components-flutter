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

import 'package:livekit_components/src/ui/widgets/theme.dart';
import '../../builder/room/media_device_select_button.dart';
import 'media_device_select_button.dart';

class CameraSelectButton extends StatelessWidget {
  const CameraSelectButton({
    super.key,
    this.showTitleWidget = true,
    this.color = Colors.grey,
    this.selectedColor = LKColors.lkBlue,
    this.iconColor = Colors.white,
    this.foregroundColor = Colors.white,
    this.selectedOverlayColor = LKColors.lkLightBlue,
    this.titleWidget,
  });

  final bool showTitleWidget;
  final Color color;
  final Color selectedColor;
  final Color iconColor;
  final Color foregroundColor;
  final Color selectedOverlayColor;
  final Widget? titleWidget;

  @override
  Widget build(BuildContext context) {
    return MediaDeviceSelectButton(
      builder: (context, roomCtx, deviceCtx) => MediaDeviceSelectWidget(
        titleWidget: titleWidget ??
            Text(
              'Camera',
              style: TextStyle(fontSize: 14, color: iconColor),
            ),
        backgroundColor: color,
        selectedColor: selectedColor,
        selectedOverlayColor: selectedOverlayColor,
        iconColor: iconColor,
        foregroundColor: foregroundColor,
        iconOn: Icons.videocam,
        iconOff: Icons.videocam_off,
        deviceList: deviceCtx.videoInputs ?? [],
        selectedDeviceId: deviceCtx.selectedVideoInputDeviceId,
        deviceIsOpened: deviceCtx.cameraOpened,
        onSelect: (device) => deviceCtx.selectVideoInput(device),
        onToggle: (enabled) =>
            enabled ? deviceCtx.enableCamera() : deviceCtx.disableCamera(),
        showTitleWidget: showTitleWidget,
      ),
    );
  }
}
