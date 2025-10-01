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

import 'package:livekit_client/livekit_client.dart' as sdk;
import 'package:provider/provider.dart';

import '../../../context/track_reference_context.dart';
import '../../../debug/logger.dart';
import 'no_track_widget.dart';

class VideoTrackWidget extends StatelessWidget {
  final sdk.VideoViewFit fit;
  final WidgetBuilder? noTrackBuilder;

  const VideoTrackWidget({
    super.key,
    this.fit = sdk.VideoViewFit.contain,
    this.noTrackBuilder,
  });

  Widget _buildNoTrack(BuildContext ctx) {
    if (noTrackBuilder != null) return noTrackBuilder!(ctx);
    return const NoTrackWidget();
  }

  @override
  Widget build(BuildContext context) {
    var trackCtx = Provider.of<TrackReferenceContext?>(context);
    final String? sid = trackCtx?.sid;

    Debug.log('===>     VideoTrackWidget for $sid');

    if (trackCtx == null || trackCtx.videoTrack == null) {
      return const NoTrackWidget();
    }

    return Selector<TrackReferenceContext, bool>(
      selector: (ctx, isMuted) => trackCtx.isMuted,
      builder: (BuildContext ctx, isMuted, child) => !isMuted && trackCtx.videoTrack != null
          ? sdk.VideoTrackRenderer(
              trackCtx.videoTrack!,
              key: ValueKey(sid),
              fit: fit,
            )
          : _buildNoTrack(ctx),
    );
  }
}
