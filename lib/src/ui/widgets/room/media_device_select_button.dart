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

class MediaDeviceSelectWidget extends StatelessWidget {
  const MediaDeviceSelectWidget({
    super.key,
    required this.iconOn,
    required this.iconOff,
    required this.deviceList,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.selectedColor,
    required this.selectedOverlayColor,
    required this.iconColor,
    required this.titleWidget,
    this.onToggle,
    this.onSelect,
    required this.deviceIsOpened,
    this.selectedDeviceId,
    this.showTitleWidget = false,
    this.defaultSelectable = false,
    this.toggleAvailable = true,
  });

  final bool deviceIsOpened;
  final Widget? titleWidget;
  final IconData iconOn;
  final IconData iconOff;
  final bool showTitleWidget;
  final Color backgroundColor;
  final Color iconColor;
  final Color selectedColor;
  final Color selectedOverlayColor;
  final Color foregroundColor;
  final String? selectedDeviceId;
  final List<MediaDevice> deviceList;
  final Function(MediaDevice device)? onSelect;
  final Function(bool enabled)? onToggle;
  final bool toggleAvailable;
  final bool defaultSelectable;

  @override
  Widget build(BuildContext context) {
    var deviceScreenType = getDeviceType(MediaQuery.of(context).size);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(deviceIsOpened
              ? selectedColor
              : backgroundColor.withValues(alpha: 0.9)),
          foregroundColor: WidgetStateProperty.all(foregroundColor),
          overlayColor: WidgetStateProperty.all(
              deviceIsOpened ? selectedOverlayColor : backgroundColor),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          shape: WidgetStateProperty.all(const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0)))),
          padding: WidgetStateProperty.all(
            (lkPlatformIsMobile() || lkPlatformIsWebMobile())
                ? const EdgeInsets.all(12)
                : const EdgeInsets.fromLTRB(12, 20, 12, 20),
          ),
        ),
        onPressed: () => onToggle?.call(!deviceIsOpened),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(deviceIsOpened || defaultSelectable ? iconOn : iconOff,
                color: iconColor),
            const SizedBox(width: 2),
            if (titleWidget != null &&
                (deviceScreenType != DeviceScreenType.mobile ||
                    showTitleWidget))
              titleWidget!,
          ],
        ),
      ),
      const SizedBox(width: 0.2),
      SizedBox(
        height: 42,
        child: PopupMenuButton<MediaDevice>(
          icon: Icon(
            Icons.arrow_drop_down,
            color: iconColor,
          ),
          offset: Offset(
              0, ((deviceList.isNotEmpty ? deviceList.length : 1) * -55.0)),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(deviceIsOpened
                ? selectedColor
                : backgroundColor.withValues(alpha: 0.9)),
            foregroundColor: WidgetStateProperty.all(foregroundColor),
            overlayColor: WidgetStateProperty.all(
                deviceIsOpened ? selectedOverlayColor : backgroundColor),
            shape: WidgetStateProperty.all(const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0)))),
          ),
          enabled: deviceIsOpened || defaultSelectable,
          itemBuilder: (BuildContext context) {
            return [
              if (deviceList.isNotEmpty)
                ...deviceList.map((device) {
                  return PopupMenuItem<MediaDevice>(
                    value: device,
                    child: ListTile(
                      selected: (device.deviceId == selectedDeviceId),
                      selectedColor: selectedColor,
                      leading: (device.deviceId == selectedDeviceId)
                          ? Icon(
                              Icons.check_box_outlined,
                              color: (device.deviceId == selectedDeviceId)
                                  ? selectedColor
                                  : backgroundColor,
                            )
                          : Icon(
                              Icons.check_box_outline_blank,
                              color: backgroundColor,
                            ),
                      title: Text(device.label),
                    ),
                    onTap: () => onSelect?.call(device),
                  );
                })
            ];
          },
        ),
      ),
    ]);
  }
}
