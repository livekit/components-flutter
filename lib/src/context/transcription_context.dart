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

import '../debug/logger.dart';
import '../types/transcription.dart';

mixin TranscriptionContextMixin on ChangeNotifier {
  List<TranscriptionForParticipant> get transcriptions => _transcriptions;
  List<TranscriptionForParticipant> _transcriptions = [];

  EventsListener<RoomEvent>? _listener;

  void transcriptionContextSetup(EventsListener<RoomEvent>? listener) {
    _listener = listener;
    if (listener != null) {
      _listener!.on<TranscriptionEvent>((event) {
        Debug.event('TranscriptionContext: TranscriptionEvent');
        List<TranscriptionForParticipant> updatedTranscriptions = List.from(_transcriptions);
        for (final segment in event.segments) {
          final findResult = updatedTranscriptions.indexWhere((t) => t.segment.id == segment.id);
          if (findResult >= 0) {
            final oldTranscription = updatedTranscriptions[findResult];
            final newTranscription = oldTranscription.copyWith(segment: segment);
            updatedTranscriptions[findResult] = newTranscription;
            Debug.event('TranscriptionContext: Replaced existing segment');
          } else {
            updatedTranscriptions.add(TranscriptionForParticipant(segment, event.participant));
            Debug.event('TranscriptionContext: Added new segment');
          }
        }
        _transcriptions = updatedTranscriptions;
        notifyListeners();
      });
    } else {
      _listener = null;
      _transcriptions.clear();
    }
  }
}
