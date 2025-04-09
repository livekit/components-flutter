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

import 'dart:async';

import 'package:flutter/material.dart' hide ConnectionState;

import 'package:livekit_client/livekit_client.dart';
import 'package:provider/provider.dart';

import 'package:livekit_components/src/context/transcription_context.dart';
import '../debug/logger.dart';
import 'chat_context.dart';

class RoomContext extends ChangeNotifier
    with ChatContextMixin, TranscriptionContextMixin {
  /// Get the [RoomContext] from the [context].
  /// this method must be called under the [LivekitRoom] widget.
  static RoomContext? of(BuildContext context) {
    return Provider.of<RoomContext?>(context);
  }

  /// Get the [ChatContextMixin] from the [context].
  /// this method must be called under the [LivekitRoom] widget.
  static ChatContextMixin? chatOf(BuildContext context) {
    return Provider.of<RoomContext?>(context);
  }

  /// Create a new [RoomContext] with the given [url] and [token].
  /// If [connect] is true, the room will be connected immediately.
  /// If [room] is provided, it will be used instead of creating a new room.
  /// If [connectOptions] is provided, it will be used to connect to the room.
  /// If [roomOptions] is provided, it will be used to create a new room.
  /// If [room] is not provided, a new room will be created with the given [roomOptions].
  /// If [url] and [token] are not provided, they must be provided when calling [Room.connect].
  RoomContext({
    String? url,
    String? token,
    Room? room,
    bool connect = false,
    RoomOptions roomOptions = const RoomOptions(),
    ConnectOptions? connectOptions,
    this.enableAudioVisulizer = false,
    this.onConnected,
    this.onDisconnected,
    this.onError,
  })  : _url = url,
        _token = token,
        _connectOptions = connectOptions {
    _room = room ?? Room(roomOptions: roomOptions);
    _listener = _room.createListener();
    _listener
      ..on<RoomConnectedEvent>((event) {
        Debug.event('RoomContext: RoomConnectedEvent $roomName');
        chatContextSetup(_listener, _room.localParticipant!);
        transcriptionContextSetup(_listener);
        _connectionState = _room.connectionState;
        _connected = true;
        _connecting = false;
        _roomMetadata = event.room.metadata;
        _activeRecording = event.room.isRecording;
        _roomName = event.room.name;
        _buildParticipants();
        onConnected?.call();
        notifyListeners();
      })
      ..on<RoomDisconnectedEvent>((event) {
        Debug.event('RoomContext: RoomDisconnectedEvent $roomName');
        _connectionState = _room.connectionState;
        chatContextSetup(null, null);
        transcriptionContextSetup(null);
        _connected = false;
        _participants.clear();
        onDisconnected?.call();
        notifyListeners();
      })
      ..on<RoomReconnectedEvent>((event) {
        Debug.event('RoomContext: RoomReconnectedEvent $roomName');
        _connectionState = _room.connectionState;
        notifyListeners();
      })
      ..on<RoomReconnectingEvent>((event) {
        Debug.event('RoomContext: RoomReconnectingEvent $roomName');
        _connectionState = _room.connectionState;
        notifyListeners();
      })
      ..on<RoomMetadataChangedEvent>((event) {
        Debug.event(
            'RoomContext: RoomMetadataChangedEvent $roomName metadata = ${event.metadata}');
        _roomMetadata = event.metadata;
        notifyListeners();
      })
      ..on<RoomRecordingStatusChanged>((event) {
        Debug.event(
            'RoomContext: RoomRecordingStatusChanged activeRecording = ${event.activeRecording}');
        _activeRecording = event.activeRecording;
        notifyListeners();
      })
      ..on<ParticipantConnectedEvent>((event) {
        Debug.event(
            'RoomContext: ParticipantConnectedEvent $roomName participant = ${event.participant.identity}');
        _buildParticipants();
      })
      ..on<ParticipantDisconnectedEvent>((event) {
        Debug.event(
            'RoomContext: ParticipantDisconnectedEvent $roomName participant = ${event.participant.identity}');
        _participants
            .removeWhere((p) => p.identity == event.participant.identity);
        notifyListeners();
      })
      ..on<TrackPublishedEvent>((event) {
        Debug.event(
            'RoomContext: TrackPublishedEvent $roomName participant = ${event.participant.identity} track = ${event.publication.sid}');
        _buildParticipants();
      })
      ..on<TrackUnpublishedEvent>((event) {
        Debug.event(
            'RoomContext: TrackUnpublishedEvent $roomName participant = ${event.participant.identity} track = ${event.publication.sid}');
        _buildParticipants();
      })
      ..on<LocalTrackPublishedEvent>((event) {
        Debug.event(
            'RoomContext: LocalTrackPublishedEvent track = ${event.publication.sid}');
        _buildParticipants();
      })
      ..on<LocalTrackUnpublishedEvent>((event) {
        Debug.event(
            'RoomContext: LocalTrackUnpublishedEvent track = ${event.publication.sid}');
        _buildParticipants();
      })
      ..on<TrackMutedEvent>((event) {
        Debug.event(
            'RoomContext: TrackMutedEvent $roomName participant = ${event.participant.identity} track = ${event.publication.sid}');
        _buildParticipants();
      })
      ..on<TrackUnmutedEvent>((event) {
        Debug.event(
            'RoomContext: TrackUnmutedEvent $roomName participant = ${event.participant.identity} track = ${event.publication.sid}');
        _buildParticipants();
      });

    if (connect && url != null && token != null) {
      _url = url;
      _token = token;
      this.connect(url: url, token: token);
    }
  }

  ///  Connect to the room with the given [url] and [token].
  Future<void> connect({
    String? url,
    String? token,
  }) async {
    if (cameraOpened || microphoneOpened) {
      _fastConnectOptions = FastConnectOptions(
        microphone: TrackOption(track: localAudioTrack),
        camera: TrackOption(track: localVideoTrack),
      );
      await resetLocalTracks();
    }

    _connectionState = ConnectionState.connecting;
    _connecting = true;
    notifyListeners();

    try {
      await _room.connect(
        url ?? _url!,
        token ?? _token!,
        fastConnectOptions: _fastConnectOptions,
        connectOptions: _connectOptions,
      );
      _url ??= url;
      _token ??= token;
      _connecting = false;
    } catch (e) {
      _connectionState = ConnectionState.disconnected;
      _connecting = false;
      notifyListeners();
      onError?.call(e as LiveKitException?);
      rethrow;
    }
  }

  Future<void> disconnect() async {
    await _room.disconnect();
    notifyListeners();
  }

  final Function()? onConnected;

  final Function()? onDisconnected;

  final Function(LiveKitException? error)? onError;

  final ConnectOptions? _connectOptions;
  FastConnectOptions? _fastConnectOptions;
  late EventsListener<RoomEvent> _listener;

  String? _url;
  String? _token;
  late Room _room;

  /// Get the [Room] instance.
  Room get room => _room;

  /// enable audio visualizer, default is false
  /// if true, the audio visualizer will be enabled in the room.
  /// you can use the [AudioVisualizerWidget] widget to show the
  /// audio visualizer.
  final bool enableAudioVisulizer;

  String? _roomName;

  /// Get the room name.
  String? get roomName => _roomName;

  String? _roomMetadata;

  /// Get the room metadata.
  String? get roomMetadata => _roomMetadata;

  bool _activeRecording = false;

  /// Get the active recording status.
  bool get activeRecording => _activeRecording;

  ConnectionState _connectionState = ConnectionState.disconnected;

  /// Get the connection state.
  ConnectionState get connectionState => _connectionState;

  bool _connecting = false;

  /// Get the connecting status.
  bool get connecting => _connecting;

  bool _connected = false;

  /// Get the connected status.
  bool get connected => _connected;

  LocalParticipant? get localParticipant => _room.localParticipant;

  int get participantCount => _participants.length;

  final List<Participant> _participants = [];

  /// Get the list of participants.
  List<Participant> get participants => _participants;

  void _buildParticipants() {
    _participants.clear();

    if (!connected) {
      return;
    }

    if (_room.localParticipant != null) {
      _participants.add(_room.localParticipant!);
    }

    _participants.addAll(_room.remoteParticipants.values);
    notifyListeners();
  }

  void pinningTrack(String sid) {
    _pinnedTracks.remove(sid);
    _pinnedTracks.insert(0, sid);
    Debug.event('Pinning track: $sid');
    notifyListeners();
  }

  void unpinningTrack(String sid) {
    _pinnedTracks.remove(sid);
    Debug.event('Unpinning track: $sid');
    notifyListeners();
  }

  void clearPinnedTracks() {
    _pinnedTracks.clear();
    notifyListeners();
  }

  final List<String> _pinnedTracks = [];
  List<String> get pinnedTracks => _pinnedTracks;

  LocalVideoTrack? _localVideoTrack;

  LocalVideoTrack? get localVideoTrack => _localVideoTrack;

  set localVideoTrack(LocalVideoTrack? track) {
    _localVideoTrack = track;
    notifyListeners();
  }

  bool get cameraOpened => isCameraEnabled ?? _localVideoTrack != null;

  bool? get isCameraEnabled => _room.localParticipant?.isCameraEnabled();

  LocalAudioTrack? _localAudioTrack;

  LocalAudioTrack? get localAudioTrack => _localAudioTrack;

  set localAudioTrack(LocalAudioTrack? track) {
    _localAudioTrack = track;
    notifyListeners();
  }

  bool get microphoneOpened => isMicrophoneEnabled ?? _localAudioTrack != null;

  bool? get isMicrophoneEnabled =>
      _room.localParticipant?.isMicrophoneEnabled();

  Future<void> resetLocalTracks() async {
    _localAudioTrack = null;
    _localVideoTrack = null;
    notifyListeners();
  }

  @override
  void dispose() async {
    await _listener.dispose();
    Debug.event('RoomContext disposed ${roomName ?? ''}');
    if (_room.connectionState == ConnectionState.connected) {
      await _room.disconnect();
    }
    await _room.dispose();
    super.dispose();
  }
}
