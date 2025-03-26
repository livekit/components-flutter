import 'package:flutter/material.dart';

import 'package:livekit_client/livekit_client.dart';
import 'package:provider/provider.dart';

import '../../../context/track_reference_context.dart';
import '../theme.dart';
import 'no_track_widget.dart';

class AudioVisualizerWidgetOptions {
  final int barCount;
  final bool centeredBands;
  final double width;
  final double minHeight;
  final double maxHeight;
  final int durationInMilliseconds;
  final Color color;
  final double spacing;
  final double cornerRadius;
  final double barMinOpacity;

  const AudioVisualizerWidgetOptions({
    this.barCount = 7,
    this.centeredBands = true,
    this.width = 12,
    this.minHeight = 12,
    this.maxHeight = 100,
    this.durationInMilliseconds = 500,
    this.color = Colors.white,
    this.spacing = 5,
    this.cornerRadius = 9999,
    this.barMinOpacity = 0.35,
  });
}

class AudioVisualizerWidget extends StatelessWidget {
  final AudioVisualizerWidgetOptions options;

  const AudioVisualizerWidget({
    Key? key,
    this.options = const AudioVisualizerWidgetOptions(),
  }) : super(key: key);

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
                options: options,
              ),
            ),
          );
        },
      ),
    );
  }
}

class SoundWaveformWidget extends StatefulWidget {
  final AudioVisualizerWidgetOptions options;
  final AudioTrack? audioTrack;

  const SoundWaveformWidget({
    super.key,
    this.audioTrack,
    this.options = const AudioVisualizerWidgetOptions(),
  });

  @override
  State<SoundWaveformWidget> createState() => _SoundWaveformWidgetState();
}

class _SoundWaveformWidgetState extends State<SoundWaveformWidget>
    with TickerProviderStateMixin {
  late AnimationController controller;
  List<double> samples = [0, 0, 0, 0, 0, 0, 0];
  AudioVisualizer? _visualizer;
  EventsListener<AudioVisualizerEvent>? _listener;

  void _startVisualizer(AudioTrack? track) async {
    if (track == null) {
      return;
    }
    samples = List.filled(widget.options.barCount, 0);
    _visualizer ??= createVisualizer(track,
        options: AudioVisualizerOptions(
            barCount: widget.options.barCount,
            centeredBands: widget.options.centeredBands));
    _listener ??= _visualizer?.createListener();
    _listener?.on<AudioVisualizerEvent>((e) {
      if (mounted) {
        setState(() {
          samples = e.event.map((e) => ((e as num) * 100).toDouble()).toList();
        });
      }
    });

    await _visualizer!.start();
  }

  void _stopVisualizer() async {
    await _visualizer?.stop();
    await _visualizer?.dispose();
    _visualizer = null;
    await _listener?.dispose();
    _listener = null;
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: widget.options.durationInMilliseconds,
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
    final count = widget.options.barCount;
    final minHeight = widget.options.minHeight;
    final maxHeight = widget.options.maxHeight;
    return AnimatedBuilder(
      animation: controller,
      builder: (c, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            count,
            (i) {
              final heightPercent =
                  ((samples[i] - minHeight) / (maxHeight - minHeight))
                      .clamp(0.0, 1.0);
              final barOpacity =
                  (1.0 - widget.options.barMinOpacity) * heightPercent +
                      widget.options.barMinOpacity;

              return AnimatedContainer(
                duration: Duration(
                    milliseconds:
                        widget.options.durationInMilliseconds ~/ count),
                margin: i == (samples.length - 1)
                    ? EdgeInsets.zero
                    : EdgeInsets.only(right: widget.options.spacing),
                height: samples[i] < minHeight
                    ? minHeight
                    : samples[i] > maxHeight
                        ? maxHeight
                        : samples[i],
                width: widget.options.width,
                decoration: BoxDecoration(
                  color: widget.options.color.withOpacity(barOpacity),
                  borderRadius:
                      BorderRadius.circular(widget.options.cornerRadius),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
