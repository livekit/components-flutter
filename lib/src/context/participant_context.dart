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

import '../debug/logger.dart';

class ParticipantContext extends ChangeNotifier {
  static int createCount = 0;

  /// Get the [ParticipantContext] from the [context].
  /// this method must be called under the [ParticipantLoop] widget.
  static ParticipantContext? of(BuildContext context) {
    return Provider.of<ParticipantContext?>(context);
  }

  ParticipantContext(this._participant)
      : _listener = _participant.createListener() {
    _listener
      ..on<SpeakingChangedEvent>((event) {
        if (event.participant.identity == identity &&
            isSpeaking != event.speaking) {
          Debug.event(
              'ParticipantContext: SpeakingChangedEvent identity = ${_participant.identity}, speaking = ${event.speaking}');
          _isSpeaking = event.speaking;
          notifyListeners();
        }
      })
      ..on<ParticipantNameUpdatedEvent>((event) {
        Debug.event(
            'ParticipantContext: ParticipantNameUpdatedEvent name = ${event.name}');
        notifyListeners();
      })
      ..on<ParticipantMetadataUpdatedEvent>((event) {
        if (event.metadata != _metadata) {
          Debug.event(
              'ParticipantContext: ParticipantMetadataUpdatedEvent metadata = ${event.metadata}');

          _metadata = event.metadata;
          notifyListeners();
        }
      })
      ..on<ParticipantConnectionQualityUpdatedEvent>((event) {
        if (event.connectionQuality != _connectionQuality) {
          Debug.event(
              'ParticipantContext: ParticipantConnectionQualityUpdatedEvent connectionQuality = ${event.connectionQuality}');

          _connectionQuality = event.connectionQuality;
          notifyListeners();
        }
      })
      ..on<ParticipantPermissionsUpdatedEvent>((event) {
        if (_permissions?.canPublish != event.permissions.canPublish ||
            _permissions?.canSubscribe != event.permissions.canSubscribe ||
            _permissions?.canPublishData != event.permissions.canPublishData ||
            _permissions?.canUpdateMetadata !=
                event.permissions.canUpdateMetadata ||
            _permissions?.canPublishSources !=
                event.permissions.canPublishSources) {
          Debug.event(
              'ParticipantContext: ParticipantPermissionsUpdatedEvent permissions canPublish = ${event.permissions.canPublish}, canSubscribe = ${event.permissions.canSubscribe}, canPublishData = ${event.permissions.canPublishData}, canUpdateMetadata = ${event.permissions.canUpdateMetadata}, canPublishSources = ${event.permissions.canPublishSources}');
          _permissions = event.permissions;
          notifyListeners();
        }
      })
      ..on<TranscriptionEvent>((e) {
        Debug.event('ParticipantContext: TranscriptionEvent');
        for (var seg in e.segments) {
          Debug.log('Transcription: ${seg.text} ${seg.isFinal}');
        }
        _segments = e.segments;
        notifyListeners();
      })
      ..on<ParticipantAttributesChanged>((event) {
        Debug.event(
            'ParticipantContext: ParticipantAttributesChanged attributes = ${event.attributes}');
        _attributes = event.attributes;
        notifyListeners();
      })
      ..on<TrackMutedEvent>((event) {
        if (event.participant.identity == identity &&
            event.publication.kind == TrackType.AUDIO) {
          Debug.event('TrackContext: TrackMutedEvent for ${_participant.sid}');
          notifyListeners();
        }
      })
      ..on<TrackUnmutedEvent>((event) {
        if (event.participant.identity == identity &&
            event.publication.kind == TrackType.AUDIO) {
          Debug.event(
              'TrackContext: TrackUnmutedEvent for ${_participant.sid}');
          notifyListeners();
        }
      });

    _metadata = _participant.metadata;
    _connectionQuality = _participant.connectionQuality;
    _permissions = _participant.permissions;
    createCount++;
    Debug.log('Participant::new count $createCount');
  }

  @override
  void dispose() {
    super.dispose();
    _listener.dispose();
    createCount--;
    Debug.log('Participant::dispose count $createCount');
  }

  bool get isLocal => _participant is LocalParticipant;

  List<TrackPublication> get tracks =>
      _participant.trackPublications.values.toList();

  final Participant _participant;
  final EventsListener<ParticipantEvent> _listener;

  bool get isEncrypted =>
      _participant.trackPublications.isNotEmpty && _participant.isEncrypted;

  String get identity => _participant.identity;

  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  ConnectionQuality _connectionQuality = ConnectionQuality.good;
  ConnectionQuality get connectionQuality => _connectionQuality;

  String? _metadata;
  String? get metadata => _metadata;

  String get name =>
      _participant.name == '' ? _participant.identity : _participant.name;

  bool get isMuted => _participant.isMuted;

  ParticipantPermissions? _permissions;
  ParticipantPermissions? get permissions => _permissions;

  Map<String, String> _attributes = {};
  Map<String, String> get attributes => _attributes;

  List<TranscriptionSegment> _segments = [];
  List<TranscriptionSegment> get segments => _segments;

  ParticipantKind get kind => _participant.kind;

  DateTime? get lastSpokeAt => _participant.lastSpokeAt;

  double get audioLevel => _participant.audioLevel;
}
