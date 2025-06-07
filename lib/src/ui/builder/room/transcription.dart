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

import '../../../context/room_context.dart';
import '../../../types/transcription.dart';

/// A builder widget that provides access to real-time transcriptions from the current room.
///
/// This widget listens to transcription updates from the room context and rebuilds
/// when new transcriptions are available. It provides a list of [TranscriptionForParticipant]
/// objects that contain transcription data for each participant in the room.
///
/// The builder function receives the current build context and a list of transcriptions,
/// allowing you to build custom UI components that display transcription data.
class TranscriptionBuilder extends StatelessWidget {
  final Function(BuildContext context, List<TranscriptionForParticipant> transcriptions) builder;

  const TranscriptionBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) => Selector<RoomContext, List<TranscriptionForParticipant>>(
        selector: (ctx, roomCtx) => roomCtx.transcriptions,
        builder: (context, transcriptions, child) => builder(
          context,
          transcriptions,
        ),
      );
}
