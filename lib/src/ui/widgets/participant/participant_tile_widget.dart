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

import '../../../context/track_reference_context.dart';
import '../../../debug/logger.dart';
import '../../builder/track/is_speaking_indicator.dart';
import '../track/focus_toggle.dart';
import '../track/track_stats_widget.dart';
import '../track/video_track_widget.dart';
import 'is_speaking_indicator.dart';
import 'participant_status_bar.dart';

class ParticipantTileWidget extends StatelessWidget {
  const ParticipantTileWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var trackCtx = Provider.of<TrackReferenceContext?>(context);
    Debug.log('>  ParticipantTile for track ${trackCtx?.sid}@${trackCtx?.participant.identity}');

    return Stack(
      children: [
        /// video track widget in the background
        IsSpeakingIndicator(builder: (context, isSpeaking) {
          return isSpeaking != null
              ? IsSpeakingIndicatorWidget(
                  isSpeaking: isSpeaking,
                  child: const VideoTrackWidget(),
                )
              : const VideoTrackWidget();
        }),

        /// focus toggle button at the top right
        const Positioned(
          top: 0,
          right: 0,
          child: FocusToggle(),
        ),

        /// track stats at the top left
        const Positioned(
          top: 8,
          left: 0,
          child: TrackStatsWidget(),
        ),

        /// status bar at the bottom
        const ParticipantStatusBar(),
      ],
    );
  }
}
