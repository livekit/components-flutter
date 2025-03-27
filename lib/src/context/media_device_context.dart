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

import 'package:flutter/material.dart';

import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:provider/provider.dart';

import '../debug/logger.dart';
import 'room_context.dart';

class MediaDeviceContext extends ChangeNotifier {
  /// Get the [MediaDeviceContext] from the [context].
  /// this method must be called under the [ControlBar] widget.
  static MediaDeviceContext? of(BuildContext context) {
    return Provider.of<MediaDeviceContext?>(context);
  }

  MediaDeviceContext({
    required RoomContext roomCtx,
  })  : _roomCtx = roomCtx,
        _room = roomCtx.room {
    loadDevices();
  }
  final RoomContext _roomCtx;
  final Room? _room;

  List<MediaDevice>? _audioInputs;
  List<MediaDevice>? _audioOutputs;
  List<MediaDevice>? _videoInputs;

  List<MediaDevice>? get audioInputs => _audioInputs;
  List<MediaDevice>? get audioOutputs => _audioOutputs;
  List<MediaDevice>? get videoInputs => _videoInputs;

  String? selectedVideoInputDeviceId;

  String? selectedAudioInputDeviceId;

  String? selectedAudioOutputDeviceId;

  bool get cameraOpened => _roomCtx.cameraOpened;

  bool get microphoneOpened => _roomCtx.microphoneOpened;

  LocalVideoTrack? get localVideoTrack => _roomCtx.localVideoTrack;

  LocalAudioTrack? get localAudioTrack => _roomCtx.localAudioTrack;

  StreamSubscription? _deviceChangeSub;

  Future<void> loadDevices() async {
    _loadDevices(await Hardware.instance.enumerateDevices());
    _deviceChangeSub =
        Hardware.instance.onDeviceChange.stream.listen(_loadDevices);
  }

  _loadDevices(List<MediaDevice> devices) {
    _audioInputs = devices.where((d) => d.kind == 'audioinput').toList();
    _audioOutputs = devices.where((d) => d.kind == 'audiooutput').toList();
    _videoInputs = devices.where((d) => d.kind == 'videoinput').toList();

    selectedAudioInputDeviceId ??=
        Hardware.instance.selectedAudioInput?.deviceId ??
            _audioInputs?.firstOrNull?.deviceId;
    selectedVideoInputDeviceId ??=
        Hardware.instance.selectedVideoInput?.deviceId ??
            _videoInputs?.firstOrNull?.deviceId;
    selectedAudioOutputDeviceId ??=
        Hardware.instance.selectedAudioOutput?.deviceId ??
            _audioOutputs?.firstOrNull?.deviceId;
    notifyListeners();
  }

  void selectAudioInput(MediaDevice device) async {
    if (_roomCtx.connected) {
      await _room?.setAudioInputDevice(device);
    } else {
      await _roomCtx.localAudioTrack?.dispose();
      _roomCtx.localAudioTrack = await LocalAudioTrack.create(
        AudioCaptureOptions(
          deviceId: selectedAudioInputDeviceId,
        ),
      );
    }
    selectedAudioInputDeviceId = device.deviceId;
    notifyListeners();
  }

  void selectAudioOutput(MediaDevice device) async {
    if (_roomCtx.connected) {
      await _room?.setAudioOutputDevice(device);
    }
    selectedAudioOutputDeviceId = device.deviceId;
    notifyListeners();
  }

  Future<void> selectVideoInput(MediaDevice device) async {
    if (_roomCtx.connected) {
      await _room?.setVideoInputDevice(device);
    } else {
      await _roomCtx.localVideoTrack?.dispose();
      _roomCtx.localVideoTrack = await LocalVideoTrack.createCameraTrack(
        CameraCaptureOptions(
          cameraPosition: currentPosition ?? CameraPosition.front,
          deviceId: device.deviceId,
        ),
      );
    }
    selectedVideoInputDeviceId = device.deviceId;
    notifyListeners();
  }

  void enableMicrophone() async {
    if (_roomCtx.microphoneOpened) {
      return;
    }
    if (_room?.localParticipant != null) {
      await _room?.localParticipant?.setMicrophoneEnabled(true);
    } else {
      _roomCtx.localAudioTrack ??= await LocalAudioTrack.create(
        AudioCaptureOptions(
          deviceId: selectedAudioInputDeviceId,
        ),
      );
    }
    notifyListeners();
  }

  void disableMicrophone() async {
    if (!_roomCtx.microphoneOpened) {
      return;
    }
    if (_roomCtx.connected) {
      await _room?.localParticipant?.setMicrophoneEnabled(false);
    } else {
      await _roomCtx.localAudioTrack?.dispose();
      _roomCtx.localAudioTrack = null;
    }
    notifyListeners();
  }

  void enableCamera() async {
    if (_roomCtx.cameraOpened) {
      return;
    }
    if (_roomCtx.connected) {
      await _room?.localParticipant?.setCameraEnabled(true,
          cameraCaptureOptions: CameraCaptureOptions(
            deviceId: selectedVideoInputDeviceId,
          ));
    } else {
      _roomCtx.localVideoTrack ??= await LocalVideoTrack.createCameraTrack(
        CameraCaptureOptions(
          cameraPosition: currentPosition ?? CameraPosition.front,
          deviceId: selectedVideoInputDeviceId,
        ),
      );
    }

    notifyListeners();
  }

  void disableCamera() async {
    if (!_roomCtx.cameraOpened) {
      return;
    }
    if (_roomCtx.connected) {
      await _room?.localParticipant?.setCameraEnabled(false);
    } else {
      await _roomCtx.localVideoTrack?.dispose();
      _roomCtx.localVideoTrack = null;
    }
    notifyListeners();
  }

  bool get isScreenShareEnabled =>
      _room?.localParticipant?.isScreenShareEnabled() ?? false;

  Future<void> enableScreenShare(context) async {
    if (lkPlatformIsDesktop()) {
      try {
        final source = await showDialog<DesktopCapturerSource>(
          context: context,
          builder: (context) => ScreenSelectDialog(),
        );
        if (source == null) {
          Debug.log('cancelled screenshare');
          return;
        }
        Debug.log('DesktopCapturerSource: ${source.id}');
        var track = await LocalVideoTrack.createScreenShareTrack(
          ScreenShareCaptureOptions(
            sourceId: source.id,
            maxFrameRate: 15.0,
          ),
        );
        await _room?.localParticipant?.publishVideoTrack(track);
      } catch (e) {
        Debug.log('could not publish video: $e');
      }
      return;
    }
    if (lkPlatformIs(PlatformType.android)) {
      // Android specific
      bool hasCapturePermission = await Helper.requestCapturePermission();
      if (!hasCapturePermission) {
        return;
      }

      requestBackgroundPermission([bool isRetry = false]) async {
        // Required for android screenshare.
        try {
          bool hasPermissions = await FlutterBackground.hasPermissions;
          if (!isRetry) {
            const androidConfig = FlutterBackgroundAndroidConfig(
              notificationTitle: 'Screen Sharing',
              notificationText: 'LiveKit Example is sharing the screen.',
              notificationImportance: AndroidNotificationImportance.normal,
              notificationIcon: AndroidResource(
                  name: 'livekit_ic_launcher', defType: 'mipmap'),
            );
            hasPermissions = await FlutterBackground.initialize(
                androidConfig: androidConfig);
          }
          if (hasPermissions &&
              !FlutterBackground.isBackgroundExecutionEnabled) {
            await FlutterBackground.enableBackgroundExecution();
          }
        } catch (e) {
          if (!isRetry) {
            return await Future<void>.delayed(const Duration(seconds: 1),
                () => requestBackgroundPermission(true));
          }
          Debug.log('could not publish video: $e');
        }
      }

      await requestBackgroundPermission();
    }
    if (lkPlatformIs(PlatformType.iOS)) {
      var track = await LocalVideoTrack.createScreenShareTrack(
        const ScreenShareCaptureOptions(
          useiOSBroadcastExtension: true,
          maxFrameRate: 15.0,
        ),
      );
      await _room?.localParticipant?.publishVideoTrack(track);
      return;
    }

    if (lkPlatformIsWebMobile()) {
      await context
          .showErrorDialog('Screen share is not supported on mobile web');
      return;
    }

    await _room?.localParticipant
        ?.setScreenShareEnabled(true, captureScreenAudio: true);
    notifyListeners();
  }

  Future<void> disableScreenShare() async {
    await _room?.localParticipant?.setScreenShareEnabled(false);
    notifyListeners();
  }

  bool get canSwitchSpeakerphone => Hardware.instance.canSwitchSpeakerphone;

  bool? get isSpeakerOn => Hardware.instance.speakerOn;

  void setSpeakerphoneOn(bool speakerOn,
      {bool forceSpeakerOutput = false}) async {
    await Hardware.instance
        .setSpeakerphoneOn(speakerOn, forceSpeakerOutput: forceSpeakerOutput);
    notifyListeners();
  }

  CameraPosition? get currentPosition {
    final track =
        _room?.localParticipant?.videoTrackPublications.firstOrNull?.track;
    if (track == null) return null;
    return (track.currentOptions as CameraCaptureOptions).cameraPosition;
  }

  void switchCamera(CameraPosition newPosition) async {
    final track =
        _room?.localParticipant?.videoTrackPublications.firstOrNull?.track;
    if (track == null) return;

    try {
      await track.setCameraPosition(newPosition);
    } catch (error) {
      print('could not restart track: $error');
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _deviceChangeSub?.cancel();
  }
}
