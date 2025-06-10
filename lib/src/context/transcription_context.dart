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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../types/transcription.dart';

mixin TranscriptionContextMixin on ChangeNotifier {
  final Map<String, TranscriptionForParticipant> _transcriptionMap = {};
  // Returns items in sorted order
  List<TranscriptionForParticipant> get transcriptions => List.unmodifiable(
      _transcriptionMap.values.sorted((a, b) => a.segment.firstReceivedTime.compareTo(b.segment.firstReceivedTime)));

  CancelListenFunc? _cancelListener;

  void transcriptionContextCleanUp() {
    _cancelListener = null;
    _transcriptionMap.clear();
  }

  // For inserting local transcription
  void insertTranscription(TranscriptionForParticipant transcriptionForParticipant) {
    _transcriptionMap[transcriptionForParticipant.segment.id] = transcriptionForParticipant;
    notifyListeners();
  }

  void transcriptionContextSetup(EventsListener<RoomEvent> listener) {
    _cancelListener = listener.on<TranscriptionEvent>((event) {
      bool hasChanged = false;

      for (final segment in event.segments) {
        final id = segment.id;
        final existing = _transcriptionMap[id];

        if (existing != null) {
          if (existing.segment != segment) {
            _transcriptionMap[id] = existing.copyWith(segment: segment);
            hasChanged = true;
          }
        } else {
          _transcriptionMap[id] = TranscriptionForParticipant(segment, event.participant);
          hasChanged = true;
        }
      }

      if (hasChanged) {
        notifyListeners();
      }
    });
  }
}
