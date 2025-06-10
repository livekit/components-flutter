import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../context/participant_context.dart';
import '../../../debug/logger.dart';

class E2EEncryptionIndicator extends StatelessWidget {
  const E2EEncryptionIndicator({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, bool isEncrypted) builder;

  @override
  Widget build(BuildContext context) {
    return Consumer<ParticipantContext>(builder: (context, participantContext, child) {
      Debug.log('====>        E2EEncryptionIndicator for ${participantContext.name}');
      return Selector<ParticipantContext, bool>(
        selector: (context, isEncrypted) => participantContext.isEncrypted,
        builder: (context, isEncrypted, child) => builder(context, isEncrypted),
      );
    });
  }
}
