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

import 'package:provider/provider.dart';

import '../../../context/track_reference_context.dart';
import '../../../debug/logger.dart';
import '../theme.dart';

class NoTrackWidget extends StatelessWidget {
  const NoTrackWidget({
    super.key,
    this.iconColor = LKColors.lkBlue,
    this.backgroundColor = LKColors.lkDarkBlue,
  });

  final Color iconColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    var trackCtx = Provider.of<TrackReferenceContext?>(context);
    final String? sid = trackCtx?.sid;
    Debug.log('===>     NoTrackWidget for $sid');

    var icon = Icons.videocam_off_outlined;
    if (trackCtx?.isAudio == true) {
      if (trackCtx?.isLocal == true) {
        if (trackCtx?.isMuted == true) {
          icon = Icons.mic_off_outlined;
        } else {
          icon = Icons.mic_none_outlined;
        }
      } else {
        if (trackCtx?.isMuted == true) {
          icon = Icons.volume_off_outlined;
        } else {
          icon = Icons.volume_up_outlined;
        }
      }
    }

    return Container(
      color: backgroundColor,
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) => Icon(
            icon,
            color: iconColor,
            size: math.min(constraints.maxHeight, constraints.maxWidth) * 0.33,
          ),
        ),
      ),
    );
  }
}
