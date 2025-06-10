import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../context/participant_context.dart';
import '../../../context/track_reference_context.dart';
import '../../../debug/logger.dart';

class IsSpeakingIndicator extends StatelessWidget {
  const IsSpeakingIndicator({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, bool? isSpeaking) builder;

  @override
  Widget build(BuildContext context) {
    var participantContext = Provider.of<ParticipantContext>(context);
    var trackCtx = Provider.of<TrackReferenceContext?>(context);

    /// Show speaking indicator only if the participant is not sharing screen
    var showSpeakingIndicator = !(trackCtx?.isScreenShare ?? true);
    Debug.log('===>     IsSpeakingIndicator for ${participantContext.name}');
    return Selector<ParticipantContext, bool>(
      selector: (context, isSpeaking) => participantContext.isSpeaking,
      builder: (context, isSpeaking, child) => builder(context, showSpeakingIndicator ? isSpeaking : null),
    );
  }
}
