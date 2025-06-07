import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart' as sdk;

@immutable
class TranscriptionForParticipant {
  final sdk.TranscriptionSegment segment;
  final sdk.Participant participant;

  const TranscriptionForParticipant(
    this.segment,
    this.participant,
  );
}

extension TranscriptionForParticipantExtension on TranscriptionForParticipant {
  TranscriptionForParticipant copyWith({
    sdk.TranscriptionSegment? segment,
    sdk.Participant? participant,
  }) =>
      TranscriptionForParticipant(
        segment ?? this.segment,
        participant ?? this.participant,
      );
}
