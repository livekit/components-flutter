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

import 'package:provider/provider.dart';

import '../../../context/participant_context.dart';
import '../../../context/track_reference_context.dart';
import '../../../debug/logger.dart';

class ParticipantName extends StatelessWidget {
  const ParticipantName({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, String? name) builder;

  @override
  Widget build(BuildContext context) {
    return Consumer<ParticipantContext>(builder: (context, participantContext, child) {
      Debug.log('====>        ParticipantName for ${participantContext.name}');
      var trackCtx = Provider.of<TrackReferenceContext?>(context);
      bool isScreenShare = trackCtx?.isScreenShare ?? false;
      return Selector<ParticipantContext, String?>(
        selector: (context, name) => participantContext.name,
        builder: (context, name, child) {
          var str = isScreenShare ? '$name\'s screen' : name;
          return builder(context, str);
        },
      );
    });
  }
}
