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

/// Identifies a track and its associated participant in a LiveKit session.
class TrackIdentifier {
  /// Creates a [TrackIdentifier] for a [participant] and an optional [track].
  TrackIdentifier(this.participant, [this.track]);

  /// The participant associated with this track.
  final Participant participant;

  /// The track publication, if available.
  final TrackPublication? track;

  /// Returns the unique identifier for the track, or the participant SID if no track is present.
  String? get identifier => track?.sid ?? participant.sid;

  /// Returns the source of the track, or [TrackSource.unknown] if not available.
  TrackSource get source => track?.source ?? TrackSource.unknown;

  /// Returns true if the track is an audio source.
  bool get isAudio =>
      source == TrackSource.microphone ||
      source == TrackSource.screenShareAudio;

  /// Returns true if the track is a video source.
  bool get isVideo =>
      source == TrackSource.camera || source == TrackSource.screenShareVideo;

  /// Returns true if the participant is local.
  bool get isLocal => participant is LocalParticipant;

  /// Returns true if a track is present.
  bool get hasTrack => track != null;

  /// Returns true if the participant is an agent.
  bool get isAgent => kind == ParticipantKind.AGENT;

  /// Returns the kind of participant (e.g., user, agent).
  ParticipantKind get kind => participant.kind;

  /// Returns the display name of the participant.
  String get name => participant.name;
}
