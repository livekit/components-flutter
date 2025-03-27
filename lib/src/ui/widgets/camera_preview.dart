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

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:livekit_client/livekit_client.dart';

import 'theme.dart';

class CameraPreviewWidget extends StatelessWidget {
  const CameraPreviewWidget({
    super.key,
    required this.track,
    this.iconColor = LKColors.lkBlue,
  });
  final LocalVideoTrack? track;
  final Color iconColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 240,
      color: LKColors.lkDarkBlue,
      child: Center(
        child: track != null
            ? VideoTrackRenderer(track!)
            : Center(
                child: LayoutBuilder(
                  builder: (context, constraints) => Icon(
                    Icons.videocam_off_outlined,
                    color: iconColor,
                    size:
                        math.min(constraints.maxHeight, constraints.maxWidth) *
                            0.33,
                  ),
                ),
              ),
      ),
    );
  }
}
