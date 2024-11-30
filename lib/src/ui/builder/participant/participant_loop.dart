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

import 'package:livekit_client/livekit_client.dart';
import 'package:provider/provider.dart';

import '../../../context/room_context.dart';
import '../../../debug/logger.dart';
import '../../../types/track_identifier.dart';
import '../../layout/grid_layout.dart';
import '../../layout/layouts.dart';
import '../../layout/sorting.dart';
import 'participant_track.dart';

typedef PaticipantTrackBuilder = Widget Function(
    BuildContext context, TrackIdentifier identifier);

class ParticipantLoop extends StatelessWidget {
  const ParticipantLoop({
    super.key,
    required this.participantTrackBuilder,
    this.layoutBuilder = const GridLayoutBuilder(),
    this.sorting = defaultSorting,
    this.showAudioTracks = false,
    this.showVideoTracks = true,
    this.showParticipantPlaceholder = true,
  });

  final PaticipantTrackBuilder participantTrackBuilder;
  final List<TrackWidget> Function(List<TrackWidget> tracks)? sorting;
  final ParticipantLayoutBuilder layoutBuilder;

  final bool showAudioTracks;
  final bool showVideoTracks;
  final bool showParticipantPlaceholder;

  List<MapEntry<TrackIdentifier, TrackPublication?>> buildTracksMap(
      bool audio, bool video, List<Participant> participants) {
    final List<MapEntry<TrackIdentifier, TrackPublication?>> trackMap = [];
    int index = 0;
    for (Participant participant in participants) {
      Debug.log('=>  participant ${participant.identity}, index: $index');
      index++;
      var tracks = participant.trackPublications.values;
      for (var track in tracks) {
        if (track.kind == TrackType.AUDIO && !audio) {
          continue;
        }
        if (track.kind == TrackType.VIDEO && !video) {
          continue;
        }
        trackMap.add(MapEntry(TrackIdentifier(participant, track), track));

        Debug.log(
            '=>  ${track.source.toString()} track ${track.sid} for ${participant.identity}');
      }

      if (!audio && !tracks.any((t) => t.kind == TrackType.VIDEO) ||
          !video && tracks.any((t) => t.kind == TrackType.AUDIO) ||
          tracks.isEmpty) {
        trackMap.add(MapEntry(TrackIdentifier(participant), null));

        Debug.log('=>  no tracks for ${participant.identity}');
      }
    }

    return trackMap;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomContext>(
      builder: (context, roomCtx, child) {
        Debug.log('>  ParticipantLoop for ${roomCtx.roomName}');

        return Selector<RoomContext, List<Participant>>(
            selector: (context, participants) => roomCtx.participants,
            shouldRebuild: (previous, next) => previous.length != next.length,
            builder: (context, participants, child) {
              List<TrackWidget> trackWidgets = [];

              var trackMap = buildTracksMap(
                  showAudioTracks, showVideoTracks, participants);

              for (var item in trackMap) {
                var identifier = item.key;
                var track = item.value;
                if (track != null) {
                  trackWidgets.add(
                    TrackWidget(
                      identifier,
                      ParticipantTrack(
                        participant: identifier.participant,
                        track: track,
                        builder: (context) =>
                            participantTrackBuilder(context, identifier),
                      ),
                    ),
                  );
                } else if (showParticipantPlaceholder) {
                  trackWidgets.add(
                    TrackWidget(
                      identifier,
                      ParticipantTrack(
                        participant: identifier.participant,
                        builder: (context) =>
                            participantTrackBuilder(context, identifier),
                      ),
                    ),
                  );
                }
              }
              if (sorting != null) {
                trackWidgets = sorting!(trackWidgets);
              }
              return Selector<RoomContext, List<String>>(
                  selector: (context, pinnedTracks) => roomCtx.pinnedTracks,
                  builder: (context, pinnedTracks, child) {
                    return layoutBuilder.build(
                        context, trackWidgets, pinnedTracks);
                  });
            });
      },
    );
  }
}
