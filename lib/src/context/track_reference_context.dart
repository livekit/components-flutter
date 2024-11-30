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

class TrackReferenceContext extends ChangeNotifier {
  /// Get the [TrackReferenceContext] from the [context].
  /// this method must be called under the [ParticipantLoop] widget.
  static TrackReferenceContext? of(BuildContext context) {
    return Provider.of<TrackReferenceContext?>(context);
  }

  TrackReferenceContext(
    this._participant, {
    required this.pub,
  }) : _listener = _participant.createListener() {
    _listener
      ..on<TrackMutedEvent>((event) {
        if (event.publication.sid == pub?.sid) {
          Debug.event('TrackContext: TrackMutedEvent for ${_participant.sid}');
          notifyListeners();
        }
      })
      ..on<TrackUnmutedEvent>((event) {
        if (event.publication.sid == pub?.sid) {
          Debug.event(
              'TrackContext: TrackUnmutedEvent for ${_participant.sid}');
          notifyListeners();
        }
      })
      ..on<LocalTrackPublishedEvent>((event) {
        if (event.publication.sid == pub?.sid) {
          Debug.event(
              'TrackContext: LocalTrackPublishedEvent for ${_participant.sid}');
          notifyListeners();
        }
      })
      ..on<TrackSubscribedEvent>((event) {
        if (event.publication.sid == pub?.sid) {
          Debug.event(
              'TrackContext: TrackSubscribedEvent for ${_participant.sid}');
          notifyListeners();
        }
      })
      ..on<TrackStreamStateUpdatedEvent>((event) {
        if (event.publication.sid == pub?.sid) {
          Debug.event(
              'TrackContext: TrackStreamStateUpdatedEvent for ${_participant.sid}');
          notifyListeners();
        }
      });
  }

  @override
  void dispose() {
    super.dispose();
    _listener.cancelAll();
    _listener.dispose();
    if (_statsListener != null) {
      _statsListener!.dispose();
    }
  }

  final Participant _participant;

  Participant get participant => _participant;
  final EventsListener<ParticipantEvent> _listener;

  final TrackPublication? pub;

  bool get isLocal => _participant is LocalParticipant;

  bool get isMuted => pub?.muted ?? true;

  VideoTrack? get videoTrack => isVideo ? pub?.track as VideoTrack? : null;

  AudioTrack? get audioTrack => isAudio ? pub?.track as AudioTrack? : null;

  bool get isScreenShare => pub?.source == TrackSource.screenShareVideo;

  bool get isVideo => pub?.kind == TrackType.VIDEO;

  bool get isAudio => pub?.kind == TrackType.AUDIO;

  String get sid => pub?.sid ?? '';

  bool _showStatistics = false;

  bool get showStatistics => _showStatistics;

  set showStatistics(bool value) {
    if (_showStatistics != value) {
      _showStatistics = value;
      if (_showStatistics) {
        if (pub!.track != null) {
          _setUpListener(pub!.track as Track);
        }
      } else {
        if (_statsListener != null) {
          _statsListener!.dispose();
        }
        _stats = {};
      }
      notifyListeners();
    }
  }

  Map<String, String> _stats = {};
  Map<String, String> get stats => _stats;
  EventsListener<TrackEvent>? _statsListener;

  void _setUpListener(Track track) {
    if (_statsListener != null) {
      _statsListener!.dispose();
    }

    _statsListener = track.createListener();

    if (track is LocalVideoTrack) {
      _statsListener?.on<VideoSenderStatsEvent>((event) {
        Map<String, String> stats = {};
        stats['tx'] = 'total sent ${event.currentBitrate.toInt()} kpbs';
        event.stats.forEach((key, value) {
          stats['layer-$key'] =
              '${value.frameWidth ?? 0}x${value.frameHeight ?? 0} ${value.framesPerSecond?.toDouble() ?? 0} fps, ${event.bitrateForLayers[key] ?? 0} kbps';
        });
        var firstStats =
            event.stats['f'] ?? event.stats['h'] ?? event.stats['q'];
        if (firstStats != null) {
          stats['encoder'] = firstStats.encoderImplementation ?? '';
          if (firstStats.mimeType != null) {
            stats['codec'] =
                '${firstStats.mimeType!.split('/')[1]}/${firstStats.clockRate}';
          }
          stats['payload'] = '${firstStats.payloadType}';
          stats['qualityLimitationReason'] =
              firstStats.qualityLimitationReason ?? '';
        }

        _stats = stats;
        notifyListeners();
      });
    } else if (track is RemoteVideoTrack) {
      _statsListener?.on<VideoReceiverStatsEvent>((event) {
        Map<String, String> stats = {};
        stats['rx'] = '${event.currentBitrate.toInt()} kpbs';
        if (event.stats.mimeType != null) {
          stats['codec'] =
              '${event.stats.mimeType!.split('/')[1]}/${event.stats.clockRate}';
        }
        stats['payload'] = '${event.stats.payloadType}';
        stats['size/fps'] =
            '${event.stats.frameWidth}x${event.stats.frameHeight} ${event.stats.framesPerSecond?.toDouble()}fps';
        stats['jitter'] = '${event.stats.jitter} s';
        stats['decoder'] = '${event.stats.decoderImplementation}';
        //stats['video packets lost'] = '${event.stats.packetsLost}';
        //stats['video packets received'] = '${event.stats.packetsReceived}';
        stats['frames received'] = '${event.stats.framesReceived}';
        stats['frames decoded'] = '${event.stats.framesDecoded}';
        stats['frames dropped'] = '${event.stats.framesDropped}';

        _stats = stats;
        notifyListeners();
      });
    } else if (track is LocalAudioTrack) {
      _statsListener?.on<AudioSenderStatsEvent>((event) {
        Map<String, String> stats = {};
        stats['tx'] = '${event.currentBitrate.toInt()} kpbs';
        if (event.stats.mimeType != null) {
          stats['codec'] =
              '${event.stats.mimeType!.split('/')[1]}/${event.stats.clockRate}/${event.stats.channels}';
        }
        stats['payload'] = '${event.stats.payloadType}';
        _stats = stats;
        notifyListeners();
      });
    } else if (track is RemoteAudioTrack) {
      _statsListener?.on<AudioReceiverStatsEvent>((event) {
        Map<String, String> stats = {};

        stats['rx'] = '${event.currentBitrate.toInt()} kpbs';
        if (event.stats.mimeType != null) {
          stats['codec'] =
              '${event.stats.mimeType!.split('/')[1]}/${event.stats.clockRate}/${event.stats.channels}';
        }
        stats['payload'] = '${event.stats.payloadType}';
        stats['jitter'] = '${event.stats.jitter} s';
        //stats['concealed samples'] =
        //    '${event.stats.concealedSamples} / ${event.stats.concealmentEvents}';
        stats['packets lost'] = '${event.stats.packetsLost}';
        stats['packets received'] = '${event.stats.packetsReceived}';

        _stats = stats;
        notifyListeners();
      });
    }
  }
}
