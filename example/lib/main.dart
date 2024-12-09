import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:livekit_components/livekit_components.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';

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

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  final url = 'wss://livekit.example.com';
  final token = 'your_token_here';

  /// handle join button pressed, fetch connection details and connect to room.
  // ignore: unused_element
  void _onJoinPressed(RoomContext roomCtx, String name, String roomName) async {
    if (kDebugMode) {
      print('Joining room: name=$name, roomName=$roomName');
    }
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
        url: url,
        token: token,
        enableAudioVisulizer: true,
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
                      token: token,
                      url: url,
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
                                flex: 5,
                                child: Stack(
                                  children: <Widget>[
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
                                                  ? const AudioVisualizerWidget()
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
