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

import '../../../context/participant_context.dart';
import '../../../debug/logger.dart';

class ParticipantTranscription extends StatelessWidget {
  const ParticipantTranscription({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, List<TranscriptionSegment> segments) builder;

  @override
  Widget build(BuildContext context) {
    return Consumer<ParticipantContext>(builder: (context, participantContext, child) {
      Debug.log('====>        ParticipantTranscription for ${participantContext.segments}');
      return Selector<ParticipantContext, List<TranscriptionSegment>>(
        selector: (context, segments) => participantContext.segments,
        builder: (context, segments, child) {
          return builder(context, segments);
        },
      );
    });
  }
}
