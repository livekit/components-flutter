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

import 'package:provider/provider.dart';

import '../../context/room_context.dart';
import '../../debug/logger.dart';
import '../builder/camera_preview.dart';
import '../builder/room/join_button.dart';
import '../widgets/camera_preview.dart';
import '../widgets/room/camera_select_button.dart';
import '../widgets/room/join_button.dart';
import '../widgets/room/microphone_select_button.dart';
import 'text_input.dart';

class Prejoin extends StatelessWidget {
  Prejoin(
      {super.key, required this.token, required this.url, this.onJoinPressed});

  final Function(RoomContext roomCtx, String url, String token)? onJoinPressed;

  String token;

  String url;

  void onTextTokenChanged(String token) async {
    this.token = token;
  }

  void onTextUrlChanged(String url) async {
    this.url = url;
  }

  void _handleJoinPressed(RoomContext roomCtx) async {
    if (onJoinPressed == null) {
      Debug.event('Joining room: $url');
      try {
        await roomCtx.connect(
          url: url,
          token: token,
        );
      } catch (e) {
        Debug.event('Failed to join room: $e');
      }
      return;
    }
    onJoinPressed?.call(roomCtx, url, token);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomContext>(
      builder: (context, roomCtx, child) => !roomCtx.connected &&
              !roomCtx.connecting
          ? Center(
              child: SizedBox(
                width: 480,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            child: CameraPreview(
                              builder: (context, videoTrack) =>
                                  CameraPreviewWidget(track: videoTrack),
                            ),
                          ),
                          SizedBox(
                            width: 360,
                            child: Container(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    MicrophoneSelectButton(),
                                    CameraSelectButton(
                                      showTitleWidget: true,
                                    ),
                                  ],
                                )),
                          ),
                          SizedBox(
                            width: 360,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                              child: TextInput(
                                onTextChanged: onTextUrlChanged,
                                hintText: 'Enter Livekit Server URL',
                                text: url,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 360,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                              child: TextInput(
                                onTextChanged: onTextTokenChanged,
                                hintText: 'Enter Token',
                                text: token,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 360,
                            height: 64,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: JoinButton(
                                builder: (context, roomCtx, connected) =>
                                    JoinButtonWidget(
                                  roomCtx: roomCtx,
                                  connected: connected,
                                  onPressed: () => _handleJoinPressed(roomCtx),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox(width: 0, height: 0),
    );
  }
}
