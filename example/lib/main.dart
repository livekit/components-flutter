import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:livekit_components/livekit_components.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final format = DateFormat('HH:mm:ss');
  // configure logs for debugging
  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('${format.format(record.time)}: ${record.message}');
    }
  });

  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: LiveKitTheme().buildThemeData(context),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  //
  const MyHomePage({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const _storeKeyUri = 'uri';
  static const _storeKeyToken = 'token';

  String _url = '';
  String _token = '';

  void _readPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _url = const bool.hasEnvironment('URL')
        ? const String.fromEnvironment('URL')
        : prefs.getString(_storeKeyUri) ?? 'your url here';
    _token = const bool.hasEnvironment('TOKEN')
        ? const String.fromEnvironment('TOKEN')
        : prefs.getString(_storeKeyToken) ?? 'your token here';
  }

  // Save URL and Token
  Future<void> _writePrefs(String url, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storeKeyUri, url);
    await prefs.setString(_storeKeyToken, token);
  }

  @override
  void initState() {
    super.initState();
    _readPrefs();
  }

  /// handle join button pressed, fetch connection details and connect to room.
  // ignore: unused_element
  void _onJoinPressed(RoomContext roomCtx, String url, String token) async {
    if (kDebugMode) {
      print('Joining room: url=$url, token=$token');
    }
    await _writePrefs(url, token);
    try {
      await roomCtx.connect(
        url: url,
        token: token,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to join room: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivekitRoom(
      roomContext: RoomContext(
        enableAudioVisulizer: true,
        onConnected: () {
          if (kDebugMode) {
            print('Connected to room');
          }
        },
        onDisconnected: () {
          if (kDebugMode) {
            print('Disconnected from room');
          }
        },
        onError: (error) {
          if (kDebugMode) {
            print('Error: $error');
          }
        },
      ),
      builder: (context, roomCtx) {
        var deviceScreenType = getDeviceType(MediaQuery.of(context).size);
        return Scaffold(
          appBar: AppBar(
            title: const Text('LiveKit Components',
                style: TextStyle(color: Colors.white)),
            actions: [
              /// show clear pin button
              if (roomCtx.connected) const ClearPinButton(),
            ],
          ),
          body: Stack(
            children: [
              !roomCtx.connected && !roomCtx.connecting

                  /// show prejoin screen if not connected
                  ? Prejoin(
                      token: _token,
                      url: _url,
                      onJoinPressed: _onJoinPressed,
                    )
                  :

                  /// show room screen if connected
                  Row(
                      children: [
                        /// show chat widget on mobile
                        (deviceScreenType == DeviceScreenType.mobile &&
                                roomCtx.isChatEnabled)
                            ? Expanded(
                                child: ChatBuilder(
                                  builder:
                                      (context, enabled, chatCtx, messages) {
                                    return ChatWidget(
                                      messages: messages,
                                      onSend: (message) =>
                                          chatCtx.sendMessage(message),
                                      onClose: () {
                                        chatCtx.toggleChat(false);
                                      },
                                    );
                                  },
                                ),
                              )
                            : Expanded(
                                flex: 6,
                                child: Stack(
                                  children: <Widget>[
                                    /* Expanded(
                                      child: TranscriptionBuilder(
                                        builder:
                                            (context, roomCtx, transcriptions) {
                                          return TranscriptionWidget(
                                            transcriptions: transcriptions,
                                          );
                                        },
                                      ),
                                    ),*/
                                    /// show participant loop
                                    ParticipantLoop(
                                      showAudioTracks: true,
                                      showVideoTracks: true,
                                      showParticipantPlaceholder: true,

                                      /// layout builder
                                      layoutBuilder:
                                          roomCtx.pinnedTracks.isNotEmpty
                                              ? const CarouselLayoutBuilder()
                                              : const GridLayoutBuilder(),

                                      /// participant builder
                                      participantTrackBuilder:
                                          (context, identifier) {
                                        // build participant widget for each Track
                                        return Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Stack(
                                            children: [
                                              /// video track widget in the background
                                              identifier.isAudio &&
                                                      roomCtx
                                                          .enableAudioVisulizer
                                                  ? const AudioVisualizerWidget(
                                                      backgroundColor:
                                                          LKColors.lkDarkBlue,
                                                    )
                                                  : IsSpeakingIndicator(
                                                      builder: (context,
                                                          isSpeaking) {
                                                        return isSpeaking !=
                                                                null
                                                            ? IsSpeakingIndicatorWidget(
                                                                isSpeaking:
                                                                    isSpeaking,
                                                                child:
                                                                    const VideoTrackWidget(),
                                                              )
                                                            : const VideoTrackWidget();
                                                      },
                                                    ),

                                              /// focus toggle button at the top right
                                              const Positioned(
                                                top: 0,
                                                right: 0,
                                                child: FocusToggle(),
                                              ),

                                              /// track stats at the top left
                                              const Positioned(
                                                top: 8,
                                                left: 0,
                                                child: TrackStatsWidget(),
                                              ),

                                              /// status bar at the bottom
                                              const Positioned(
                                                bottom: 0,
                                                left: 0,
                                                right: 0,
                                                child: ParticipantStatusBar(),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),

                                    /// show control bar at the bottom
                                    const Positioned(
                                      bottom: 30,
                                      left: 0,
                                      right: 0,
                                      child: ControlBar(),
                                    ),
                                  ],
                                ),
                              ),

                        /// show chat widget on desktop
                        (deviceScreenType != DeviceScreenType.mobile &&
                                roomCtx.isChatEnabled)
                            ? Expanded(
                                flex: 2,
                                child: SizedBox(
                                  width: 400,
                                  child: ChatBuilder(
                                    builder:
                                        (context, enabled, chatCtx, messages) {
                                      return ChatWidget(
                                        messages: messages,
                                        onSend: (message) =>
                                            chatCtx.sendMessage(message),
                                        onClose: () {
                                          chatCtx.toggleChat(false);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              )
                            : const SizedBox(width: 0, height: 0),
                      ],
                    ),

              /// show toast widget
              const Positioned(
                top: 30,
                left: 0,
                right: 0,
                child: ToastWidget(),
              ),
            ],
          ),
        );
      },
    );
  }
}
