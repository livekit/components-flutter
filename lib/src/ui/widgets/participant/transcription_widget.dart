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

import '../../../types/transcription.dart';

class TranscriptionMessageBubble extends StatelessWidget {
  final TranscriptionForParticipant transcriptionForParticipant;

  TranscriptionMessageBubble({required this.transcriptionForParticipant});

  @override
  Widget build(BuildContext context) {
    final participant = transcriptionForParticipant.participant;
    final isLocal = participant is LocalParticipant;

    return LayoutBuilder(
      builder: (ctx, c) => Container(
        alignment: isLocal ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: c.maxWidth * 0.9),
          decoration: isLocal
              ? BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                )
              : null,
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(10),
          child: Text(
            transcriptionForParticipant.segment.text + (transcriptionForParticipant.segment.isFinal ? '' : ' ...'),
            textAlign: isLocal ? TextAlign.end : TextAlign.start,
          ),
        ),
      ),
    );
  }
}

class TranscriptionWidget extends StatelessWidget {
  TranscriptionWidget({
    super.key,
    required this.transcriptions,
    this.padding,
  });

  final EdgeInsetsGeometry? padding;
  final List<TranscriptionForParticipant> transcriptions;

  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: padding,
        itemCount: transcriptions.length,
        reverse: true,
        itemBuilder: (ctx, i) {
          final segment = transcriptions.reversed.toList()[i];
          return TranscriptionMessageBubble(transcriptionForParticipant: segment);
        },
      );
}
