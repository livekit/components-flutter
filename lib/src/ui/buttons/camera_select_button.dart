import 'package:flutter/material.dart';

import 'package:livekit_client/livekit_client.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../context/media_device.dart';
import '../../context/room.dart';
import '../../types/theme.dart';

class CameraSelectButton extends StatelessWidget {
  const CameraSelectButton({super.key, this.showLabel = false});

  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomContext>(
      builder: (context, roomCtx, child) {
        return ChangeNotifierProvider(
          create: (_) => MediaDeviceContext(roomCtx: roomCtx),
          child: Consumer<MediaDeviceContext>(
            builder: (context, deviceCtx, child) {
              var deviceScreenType = getDeviceType(MediaQuery.of(context).size);
              return Row(mainAxisSize: MainAxisSize.min, children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                        deviceCtx.cameraOpened
                            ? LKColors.lkBlue
                            : Colors.grey.withOpacity(0.6)),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                    overlayColor: WidgetStateProperty.all(deviceCtx.cameraOpened
                        ? LKColors.lkLightBlue
                        : Colors.grey),
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
                  onPressed: () => deviceCtx.cameraOpened
                      ? deviceCtx.disableCamera()
                      : deviceCtx.enableCamera(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(deviceCtx.cameraOpened
                          ? Icons.videocam
                          : Icons.videocam_off),
                      if (deviceScreenType != DeviceScreenType.mobile ||
                          showLabel)
                        const Text('Camera'),
                    ],
                  ),
                ),
                const SizedBox(width: 0.2),
                Selector<RoomContext, String?>(
                  selector: (context, roomCtx) =>
                      deviceCtx.selectedVideoInputDeviceId,
                  builder: (context, selectedVideoInputDeviceId, child) {
                    return PopupMenuButton<MediaDevice>(
                      padding: const EdgeInsets.all(12),
                      offset: Offset(
                          0, ((deviceCtx.videoInputs?.length ?? 1) * -55.0)),
                      icon: const Icon(Icons.arrow_drop_down),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                            Colors.grey.withOpacity(0.6)),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                        overlayColor: WidgetStateProperty.all(Colors.grey),
                        elevation: WidgetStateProperty.all(20),
                        shape: WidgetStateProperty.all(
                            const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(20.0),
                                    bottomRight: Radius.circular(20.0)))),
                      ),
                      enabled: deviceCtx.cameraOpened,
                      itemBuilder: (BuildContext context) {
                        return [
                          if (deviceCtx.videoInputs != null)
                            ...deviceCtx.videoInputs!.map((device) {
                              return PopupMenuItem<MediaDevice>(
                                value: device,
                                child: ListTile(
                                  selected: (device.deviceId ==
                                      selectedVideoInputDeviceId),
                                  selectedColor: LKColors.lkBlue,
                                  leading: (device.deviceId ==
                                          selectedVideoInputDeviceId)
                                      ? Icon(
                                          Icons.check_box_outlined,
                                          color: (device.deviceId ==
                                                  selectedVideoInputDeviceId)
                                              ? LKColors.lkBlue
                                              : Colors.white,
                                        )
                                      : const Icon(
                                          Icons.check_box_outline_blank,
                                          color: Colors.white,
                                        ),
                                  title: Text(device.label),
                                ),
                                onTap: () => deviceCtx.selectVideoInput(device),
                              );
                            })
                        ];
                      },
                    );
                  },
                ),
              ]);
            },
          ),
        );
      },
    );
  }
}