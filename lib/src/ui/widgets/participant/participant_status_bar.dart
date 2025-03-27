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

import '../../../context/participant_context.dart';
import '../../../context/track_reference_context.dart';
import '../../../debug/logger.dart';
import '../../builder/participant/participant_muted_indicator.dart';
import '../../builder/participant/participant_name.dart';
import '../../builder/track/connection_quality_indicator.dart';
import '../../builder/track/e2e_encryption_indicator.dart';
import 'connection_quality_indicator.dart';

class ParticipantStatusBar extends StatelessWidget {
  const ParticipantStatusBar({
    super.key,
    this.showName = true,
    this.showE2EEStatus = true,
    this.showConnectionQuality = true,
    this.showMuteStatus = true,
  });

  final bool showName;
  final bool showE2EEStatus;
  final bool showConnectionQuality;
  final bool showMuteStatus;

  @override
  Widget build(BuildContext context) {
    return Consumer<ParticipantContext>(
      builder: (context, participantContext, child) {
        Debug.log(
            '===>     ParticipantStatusBar for ${participantContext.name}');
        var trackCtx = Provider.of<TrackReferenceContext?>(context);
        var isScreenShare = trackCtx?.isScreenShare ?? false;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          color: Colors.black.withValues(alpha: 0.6),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showMuteStatus && !isScreenShare)
                  ParticipantMutedIndicator(
                    builder: (context, isMuted) => isMuted
                        ? const Icon(
                            Icons.mic_off,
                            color: Colors.white54,
                            size: 20,
                          )
                        : const SizedBox(),
                  ),
                if (isScreenShare)
                  const Icon(
                    Icons.screen_share,
                    color: Colors.white54,
                    size: 20,
                  ),
                if (showName)
                  ParticipantName(
                    builder: (context, name) => name != null
                        ? Flexible(
                            child: Text(
                              isScreenShare ? '$name\'s screen' : name,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        : Container(),
                  ),
                if (showConnectionQuality)
                  ConnectionQualityIndicator(
                    builder: (context, connectionQuality) =>
                        ConnectionQualityIndicatorWidget(
                      connectionQuality: connectionQuality,
                    ),
                  ),
                if (showE2EEStatus)
                  E2EEncryptionIndicator(
                    builder: (context, isEncrypted) => Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Icon(
                        isEncrypted ? Icons.lock : Icons.lock_open,
                        color: Colors.white54,
                        size: 20,
                      ),
                    ),
                  ),
              ]),
        );
      },
    );
  }
}
