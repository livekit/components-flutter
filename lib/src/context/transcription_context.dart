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

import 'package:collection/collection.dart';
import 'package:livekit_client/livekit_client.dart';

import '../debug/logger.dart';
import '../types/transcription.dart';

mixin TranscriptionContextMixin on ChangeNotifier {
  final List<TranscriptionForParticipant> _transcriptions = [];
  List<TranscriptionForParticipant> get transcriptions => _transcriptions;
  EventsListener<RoomEvent>? _listener;

  void transcriptionContextSetup(EventsListener<RoomEvent>? listener) {
    _listener = listener;
    if (listener != null) {
      _listener!.on<TranscriptionEvent>((event) {
        Debug.event('TranscriptionContext: TranscriptionEvent');
        for (var segment in event.segments) {
          var transcription = _transcriptions
              .firstWhereOrNull((t) => t.segment.id == segment.id);
          if (transcription != null) {
            transcription.segment = segment;
          } else {
            _transcriptions
                .add(TranscriptionForParticipant(segment, event.participant));
          }
        }
        notifyListeners();
      });
    } else {
      _listener = null;
      _transcriptions.clear();
    }
  }
}
