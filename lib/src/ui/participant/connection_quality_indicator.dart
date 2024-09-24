import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:provider/provider.dart';

import '../../context/participant.dart';

class ConnectionQualityIndicator extends StatelessWidget {
  const ConnectionQualityIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ParticipantContext>(
      builder: (context, participantContext, child) =>
          Selector<ParticipantContext, ConnectionQuality>(
        selector: (context, connectionQuality) =>
            participantContext.connectionQuality,
        builder: (context, connectionQuality, child) => Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Icon(
            connectionQuality == ConnectionQuality.poor
                ? Icons.wifi_off_outlined
                : Icons.wifi,
            color: {
              ConnectionQuality.excellent: Colors.green,
              ConnectionQuality.good: Colors.orange,
              ConnectionQuality.poor: Colors.red,
            }[connectionQuality],
            size: 16,
          ),
        ),
      ),
    );
  }
}
