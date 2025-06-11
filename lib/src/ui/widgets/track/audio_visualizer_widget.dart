import 'dart:math' show max;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' as sdk;
import 'package:provider/provider.dart';

import '../../../context/track_reference_context.dart';
import '../../../types/agent_state.dart';

class AudioVisualizerWidgetOptions {
  final int barCount;
  final bool centeredBands;
  final double width;
  final double minHeight;
  final double maxHeight;
  final int durationInMilliseconds;
  final Color? color;
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
    this.color,
    this.spacing = 5,
    this.cornerRadius = 9999,
    this.barMinOpacity = 0.2,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudioVisualizerWidgetOptions &&
        other.barCount == barCount &&
        other.centeredBands == centeredBands &&
        other.width == width &&
        other.minHeight == minHeight &&
        other.maxHeight == maxHeight &&
        other.durationInMilliseconds == durationInMilliseconds &&
        other.color == color &&
        other.spacing == spacing &&
        other.cornerRadius == cornerRadius &&
        other.barMinOpacity == barMinOpacity;
  }

  @override
  int get hashCode {
    return Object.hash(
      barCount,
      centeredBands,
      width,
      minHeight,
      maxHeight,
      durationInMilliseconds,
      color,
      spacing,
      cornerRadius,
      barMinOpacity,
    );
  }
}

extension _ComputeExt on AudioVisualizerWidgetOptions {
  Color computeColor(BuildContext ctx) => color ?? Theme.of(ctx).colorScheme.primary;
}

class AudioVisualizerWidget extends StatelessWidget {
  final AudioVisualizerWidgetOptions options;
  final Color backgroundColor;

  const AudioVisualizerWidget({
    Key? key,
    this.backgroundColor = Colors.transparent,
    this.options = const AudioVisualizerWidgetOptions(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<TrackReferenceContext?>(
        builder: (BuildContext context, TrackReferenceContext? trackCtx, Widget? child) => Container(
          color: backgroundColor,
          child: SoundWaveformWidget(
            audioTrack: trackCtx?.audioTrack,
            participant: trackCtx?.participant,
            options: options,
          ),
        ),
      );
}

class SoundWaveformWidget extends StatefulWidget {
  final sdk.Participant? participant;
  final sdk.AudioTrack? audioTrack;
  final AudioVisualizerWidgetOptions options;

  const SoundWaveformWidget({
    super.key,
    this.participant,
    this.audioTrack,
    this.options = const AudioVisualizerWidgetOptions(),
  });

  @override
  State<SoundWaveformWidget> createState() => _SoundWaveformWidgetState();
}

const agentStateAttributeKey = 'lk.agent.state';

class _SoundWaveformWidgetState extends State<SoundWaveformWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  List<double> samples = [];

  sdk.AudioVisualizer? _visualizer;
  sdk.EventsListener<sdk.AudioVisualizerEvent>? _visualizerListener;
  sdk.EventsListener<sdk.ParticipantEvent>? _participantListener;

  // Agent support
  AgentState _agentState = AgentState.initializing;

  @override
  void didUpdateWidget(SoundWaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final didUpdateParams = oldWidget.participant?.sid != widget.participant?.sid ||
        oldWidget.audioTrack?.sid != widget.audioTrack?.sid ||
        oldWidget.options != widget.options;

    if (didUpdateParams) {
      // Re-attach listeners
      _detachListeners();
      _attachListeners();
    }
  }

  Future<void> _attachListeners() async {
    print('Attach listeners... ${widget.participant}, ${widget.audioTrack}');

    if (widget.participant != null) {
      _participantListener = widget.participant!.createListener();
      _participantListener?.on<sdk.TrackMutedEvent>((e) {
        if (!mounted) return;
        setState(() {
          samples = List.filled(widget.options.barCount, 0.0);
        });
      });

      // If participant is agent, listen to agent state changes
      if (widget.participant?.kind == sdk.ParticipantKind.AGENT) {
        _participantListener?.on<sdk.ParticipantAttributesChanged>((e) {
          if (!mounted) return;
          final agentStateString = e.attributes[agentStateAttributeKey];
          setState(() {
            _agentState = agentStateString != null ? AgentState.fromString(agentStateString) : AgentState.initializing;
          });
        });
      }
    }

    if (widget.audioTrack != null) {
      _visualizer = sdk.createVisualizer(widget.audioTrack!,
          options: sdk.AudioVisualizerOptions(
              barCount: widget.options.barCount, centeredBands: widget.options.centeredBands));
      _visualizerListener = _visualizer?.createListener();
      _visualizerListener?.on<sdk.AudioVisualizerEvent>((e) {
        if (!mounted) return;
        setState(() {
          samples = e.event.map((e) => ((e as num)).toDouble()).toList();
        });
      });

      print('Visualizer: Start... ${_visualizer?.visualizerId}');
      await _visualizer!.start();
    }
  }

  Future<void> _detachListeners() async {
    if (_visualizer != null) {
      print('Visualizer: Stop ${_visualizer?.visualizerId} ...');
      await _visualizer?.stop();
      await _visualizer?.dispose();
      _visualizer = null;
    }

    await _visualizerListener?.dispose();
    _visualizerListener = null;
    await _participantListener?.dispose();
    _participantListener = null;
  }

  @override
  void initState() {
    super.initState();

    samples = List.filled(widget.options.barCount, 0.0);

    _controller = AnimationController(
      duration: Duration(milliseconds: widget.options.durationInMilliseconds),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _attachListeners();
  }

  @override
  void dispose() {
    _controller.dispose();
    _detachListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get center index
    final centerIndex = (samples.length / 2).floor();

    return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (ctx, _) {
          // Thinking state - animate ball moving from left to right and back
          if (widget.participant?.kind == sdk.ParticipantKind.AGENT && _agentState == AgentState.thinking) {
            final activeIndex = (_pulseAnimation.value * (samples.length - 1)).round();
            final elements = List.generate(
              samples.length,
              (i) {
                final distance = (i - activeIndex).abs();
                final maxDistance = samples.length / 4;
                final gradientStrength = (1.0 - (distance / maxDistance)).clamp(0.0, 1.0);
                final alpha = widget.options.barMinOpacity + 
                    (gradientStrength * (1.0 - widget.options.barMinOpacity));
                
                return BarsViewItem(
                    value: samples[i],
                    color: widget.options.computeColor(ctx).withValues(alpha: alpha));
              },
            );
            return BarsView(
              options: widget.options,
              elements: elements,
            );
          }

          // Listening state
          if (widget.participant == null ||
              widget.participant?.kind == sdk.ParticipantKind.AGENT &&
                  (_agentState == AgentState.initializing || _agentState == AgentState.listening)) {
            final elements = List.generate(
              samples.length,
              (i) => BarsViewItem(
                  value: samples[i],
                  color: i == centerIndex
                      ? widget.options.computeColor(ctx).withValues(alpha: 0.1 + (_pulseAnimation.value - 0.1))
                      : widget.options.computeColor(ctx).withValues(alpha: 0.1)),
            );
            return BarsView(
              options: widget.options,
              elements: elements,
            );
          }

          final elements = List.generate(
            samples.length,
            (i) => BarsViewItem(value: samples[i], color: widget.options.computeColor(ctx)),
          );

          return BarsView(
            options: widget.options,
            elements: elements,
          );
        });
  }
}

class BarsViewItem {
  final double value;
  final Color color;

  BarsViewItem({
    required this.value,
    required this.color,
  });
}

class BarsView extends StatelessWidget {
  final AudioVisualizerWidgetOptions options;
  final List<BarsViewItem> elements;

  const BarsView({
    super.key,
    required this.options,
    required this.elements,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final delta = (constraints.maxWidth / elements.length) - options.spacing;

          return Row(
            mainAxisSize: MainAxisSize.min,
            spacing: options.spacing,
            children: elements
                .mapIndexed(
                  (index, element) => Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: options.durationInMilliseconds ~/ options.barCount),
                      decoration: BoxDecoration(
                        color: element.color,
                        borderRadius: BorderRadius.circular(options.cornerRadius),
                      ),
                      height: max(delta, (element.value * (constraints.maxHeight - delta)) + delta),
                    ),
                  ),
                )
                .toList(),
          );
        },
      );
}
