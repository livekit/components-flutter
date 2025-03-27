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

class TrackIdentifier {
  TrackIdentifier(this.participant, [this.track]);
  final Participant participant;
  final TrackPublication? track;

  String? get identifier => track?.sid ?? participant.sid;

  TrackSource get source => track?.source ?? TrackSource.unknown;

  bool get isAudio =>
      source == TrackSource.microphone ||
      source == TrackSource.screenShareAudio;

  bool get isVideo =>
      source == TrackSource.camera || source == TrackSource.camera;

  bool get isLocal => participant is LocalParticipant;

  bool get hasTrack => track != null;

  bool get isAgent => kind == ParticipantKind.AGENT;

  ParticipantKind get kind => participant.kind;

  String get name => participant.name;
}
