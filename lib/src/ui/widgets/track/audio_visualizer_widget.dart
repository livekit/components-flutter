import 'package:flutter/material.dart';

import 'package:livekit_client/livekit_client.dart';
import 'package:provider/provider.dart';

import '../../../context/track_reference_context.dart';
import '../theme.dart';
import 'no_track_widget.dart';

class AudioVisualizerWidget extends StatelessWidget {
  const AudioVisualizerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var trackCtx = Provider.of<TrackReferenceContext?>(context);

    if (trackCtx == null) {
      return const NoTrackWidget();
    }

    return Consumer<TrackReferenceContext>(
      builder: (context, trackCtx, child) =>
          Selector<TrackReferenceContext, AudioTrack?>(
        selector: (context, audioTrack) => trackCtx.audioTrack,
        builder: (BuildContext context, AudioTrack? audioTrack, Widget? child) {
          if (trackCtx.audioTrack == null) {
            return const NoTrackWidget();
          }
          return Container(
            color: LKColors.lkDarkBlue,
            child: Center(
              child: SoundWaveformWidget(
                audioTrack: audioTrack,
                count: 7,
                width: 12,
                minHeight: 12,
                maxHeight: 100,
                durationInMilliseconds: 500,
              ),
            ),
          );
        },
      ),
    );
  }
}

class SoundWaveformWidget extends StatefulWidget {
  final int count;
  final double width;
  final double minHeight;
  final double maxHeight;
  final int durationInMilliseconds;
  const SoundWaveformWidget({
    super.key,
    this.audioTrack,
    this.count = 7,
    this.width = 5,
    this.minHeight = 8,
    this.maxHeight = 100,
    this.durationInMilliseconds = 500,
  });
  final AudioTrack? audioTrack;
  @override
  State<SoundWaveformWidget> createState() => _SoundWaveformWidgetState();
}

class _SoundWaveformWidgetState extends State<SoundWaveformWidget>
    with TickerProviderStateMixin {
  late AnimationController controller;
  List<double> samples = [0, 0, 0, 0, 0, 0, 0];
  EventsListener<TrackEvent>? _listener;

  void _startVisualizer(AudioTrack? track) async {
    _listener = track?.createListener();
    _listener
      ?..on<AudioVisualizerEvent>((e) {
        if (mounted) {
          setState(() {
            samples =
                e.event.map((e) => ((e as num) * 100).toDouble()).toList();
          });
        }
      })
      ..on<TrackMutedEvent>((e) {
        if (mounted) {
          setState(() {
            samples = List.filled(samples.length, 0);
          });
        }
      });
  }

  void _stopVisualizer() async {
    await _listener?.dispose();
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: widget.durationInMilliseconds,
        ))
      ..repeat();

    _startVisualizer(widget.audioTrack);
  }

  @override
  void dispose() {
    controller.dispose();
    _stopVisualizer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.count;
    final minHeight = widget.minHeight;
    final maxHeight = widget.maxHeight;
    return AnimatedBuilder(
      animation: controller,
      builder: (c, child) {
        //double t = controller.value;
        //int current = (samples.length * t).floor();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            count,
            (i) => AnimatedContainer(
              duration: Duration(
                  milliseconds: widget.durationInMilliseconds ~/ count),
              margin: i == (samples.length - 1)
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(right: 5),
              height: samples[i] < minHeight
                  ? minHeight
                  : samples[i] > maxHeight
                      ? maxHeight
                      : samples[i],
              width: widget.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
        );
      },
    );
  }
}
