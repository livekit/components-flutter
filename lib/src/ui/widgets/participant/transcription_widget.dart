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

import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../types/transcription.dart';
import '../theme.dart';

class TranscriptionWidget extends StatelessWidget {
  TranscriptionWidget({
    super.key,
    required this.transcriptions,
    this.backgroundColor = LKColors.lkDarkBlue,
    this.textColor = Colors.white,
  });

  final Color backgroundColor;
  final Color textColor;
  final List<TranscriptionForParticipant> transcriptions;
  final ScrollController _scrollController = ScrollController();

  List<Widget> _buildMessages(
      List<TranscriptionForParticipant> transcriptions) {
    List<Widget> msgWidgets = [];
    var sortedTranscriptions = transcriptions
      ..sort((a, b) =>
          a.segment.firstReceivedTime.compareTo(b.segment.firstReceivedTime));
    for (var transcription in sortedTranscriptions) {
      var participant = transcription.participant;
      var segment = transcription.segment;
      var isLocal = participant is LocalParticipant;
      msgWidgets.add(
        BubbleNormal(
          text: segment.text + (segment.isFinal ? '' : '...'),
          color: textColor,
          tail: isLocal,
          isSender: isLocal,
        ),
      );
    }
    return msgWidgets;
  }

  void scrollToBottom() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(1.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: _buildMessages(transcriptions),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
