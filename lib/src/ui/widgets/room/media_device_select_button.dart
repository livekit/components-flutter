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

import '../theme.dart';

class MediaDeviceSelectWidget extends StatelessWidget {
  const MediaDeviceSelectWidget({
    super.key,
    required this.iconOn,
    required this.iconOff,
    required this.deviceList,
    this.title,
    this.onToggle,
    this.onSelect,
    required this.deviceIsOpened,
    this.selectedDeviceId,
    this.showLabel = false,
    this.defaultSelectable = false,
    this.toggleAvailable = true,
  });

  final bool deviceIsOpened;
  final String? title;
  final IconData iconOn;
  final IconData iconOff;
  final bool showLabel;
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
          backgroundColor: WidgetStateProperty.all(
              deviceIsOpened ? LKColors.lkBlue : Colors.grey.withOpacity(0.9)),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          overlayColor: WidgetStateProperty.all(
              deviceIsOpened ? LKColors.lkLightBlue : Colors.grey),
          shape: WidgetStateProperty.all(const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0)))),
          padding: WidgetStateProperty.all(
            deviceScreenType == DeviceScreenType.desktop ||
                    lkPlatformIsDesktop()
                ? const EdgeInsets.fromLTRB(10, 20, 10, 20)
                : const EdgeInsets.all(12),
          ),
        ),
        onPressed: () => onToggle?.call(!deviceIsOpened),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(deviceIsOpened || defaultSelectable ? iconOn : iconOff),
            const SizedBox(width: 2),
            if (title != null &&
                (deviceScreenType != DeviceScreenType.mobile || showLabel))
              Text(
                title!,
                style: TextStyle(fontSize: 14),
              ),
          ],
        ),
      ),
      const SizedBox(width: 0.2),
      PopupMenuButton<MediaDevice>(
        padding: const EdgeInsets.all(12),
        icon: const Icon(Icons.arrow_drop_down),
        offset: Offset(
            0, ((deviceList.isNotEmpty ? deviceList.length : 1) * -55.0)),
        style: ButtonStyle(
          backgroundColor:
              WidgetStateProperty.all(Colors.grey.withOpacity(0.9)),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          overlayColor: WidgetStateProperty.all(Colors.grey),
          elevation: WidgetStateProperty.all(20),
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
                    selectedColor: LKColors.lkBlue,
                    leading: (device.deviceId == selectedDeviceId)
                        ? Icon(
                            Icons.check_box_outlined,
                            color: (device.deviceId == selectedDeviceId)
                                ? LKColors.lkBlue
                                : Colors.white,
                          )
                        : const Icon(
                            Icons.check_box_outline_blank,
                            color: Colors.white,
                          ),
                    title: Text(device.label),
                  ),
                  onTap: () => onSelect?.call(device),
                );
              })
          ];
        },
      ),
    ]);
  }
}
