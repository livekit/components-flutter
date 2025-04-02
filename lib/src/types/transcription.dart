import 'package:livekit_client/livekit_client.dart'
    show Participant, TranscriptionSegment;

class TranscriptionForParticipant {
  TranscriptionForParticipant(
    this.segment,
    this.participant,
  );
  TranscriptionSegment segment;
  final Participant participant;
}
