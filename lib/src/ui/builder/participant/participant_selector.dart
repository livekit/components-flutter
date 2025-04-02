import 'package:flutter/widgets.dart';

import 'package:collection/collection.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:provider/provider.dart';

import 'package:livekit_components/src/types/track_identifier.dart';
import '../../../context/room_context.dart';
import '../../../debug/logger.dart';
import 'participant_track.dart';

class ParticipantSelector extends StatelessWidget {
  final bool Function(TrackIdentifier identifier) filter;
  final Widget Function(BuildContext context, TrackIdentifier identifier)
      builder;
  const ParticipantSelector({
    required this.filter,
    required this.builder,
    super.key,
  });

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
        Debug.log('>  ParticipantSelector for ${roomCtx.roomName}');
        return Selector<RoomContext, List<Participant>>(
          selector: (context, participants) => roomCtx.participants,
          shouldRebuild: (previous, next) => previous.length != next.length,
          builder: (context, participants, child) {
            var trackMap = buildTracksMap(true, true, participants);
            var identifier =
                trackMap.firstWhereOrNull((entry) => filter(entry.key))?.key;

            if (identifier == null) {
              return const SizedBox();
            }

            return ParticipantTrack(
              participant: identifier.participant,
              track: identifier.track,
              builder: (context) => builder(context, identifier),
            );
          },
        );
      },
    );
  }
}
