import 'package:flutter/material.dart';

import 'package:livekit_client/livekit_client.dart';
import 'package:provider/provider.dart';

import '../../../context/participant_context.dart';
import '../../../debug/logger.dart';

class ConnectionQualityIndicator extends StatelessWidget {
  const ConnectionQualityIndicator({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, ConnectionQuality connectionQuality) builder;

  @override
  Widget build(BuildContext context) {
    return Consumer<ParticipantContext>(builder: (context, participantContext, child) {
      Debug.log('====>        ConnectionQualityIndicator for ${participantContext.name}');
      return Selector<ParticipantContext, ConnectionQuality>(
        selector: (context, connectionQuality) => participantContext.connectionQuality,
        builder: (context, connectionQuality, child) => builder(context, connectionQuality),
      );
    });
  }
}
