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

import 'package:livekit_client/livekit_client.dart';

import 'layouts.dart';

List<TrackWidget> defaultSorting(List<TrackWidget> trackWidgets) {
  final trackWidgetsSorted = <TrackWidget>[];

  /// sort screen shares and local participant first
  for (var element in trackWidgets) {
    if (element.trackIdentifier.track?.isScreenShare == true ||
        element.trackIdentifier.participant is LocalParticipant) {
      trackWidgetsSorted.insert(0, element);
    } else {
      trackWidgetsSorted.add(element);
    }
  }

  // sort speakers for the grid
  trackWidgetsSorted.sort((a, b) {
    // loudest speaker first
    final participantA = a.trackIdentifier.participant;
    final participantB = b.trackIdentifier.participant;
    if (participantA.isSpeaking && participantB.isSpeaking) {
      if (participantA.audioLevel > participantB.audioLevel) {
        return -1;
      } else {
        return 1;
      }
    }

    // last spoken at
    final aSpokeAt = participantA.lastSpokeAt?.millisecondsSinceEpoch ?? 0;
    final bSpokeAt = participantB.lastSpokeAt?.millisecondsSinceEpoch ?? 0;

    if (aSpokeAt != bSpokeAt) {
      return aSpokeAt > bSpokeAt ? -1 : 1;
    }

    // video on
    if (participantA.hasVideo != participantB.hasVideo) {
      return participantA.hasVideo ? -1 : 1;
    }

    // joinedAt
    return participantA.joinedAt.millisecondsSinceEpoch - participantB.joinedAt.millisecondsSinceEpoch;
  });

  return trackWidgetsSorted;
}
