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
            key: ValueKey('SoundWaveformWidget-${trackCtx?.participant.sid}-${trackCtx?.audioTrack?.sid}'),
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
    if (oldWidget.participant?.sid != widget.participant?.sid ||
        oldWidget.audioTrack?.sid != widget.audioTrack?.sid ||
        oldWidget.options != widget.options) {
      // Re-attach listeners
      _detachListeners();
      _attachListeners();
    }
  }

  Future<void> _attachListeners() async {
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

      await _visualizer!.start();
    }
  }

  Future<void> _detachListeners() async {
    await _visualizer?.stop();
    await _visualizer?.dispose();
    _visualizer = null;
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
          // Listening state
          if (widget.participant?.kind == sdk.ParticipantKind.AGENT &&
              (_agentState == AgentState.initializing || _agentState == AgentState.listening)) {
            final elements = List.generate(
              samples.length,
              (i) => BarsViewItem(
                  value: samples[i],
                  color: i == centerIndex
                      ? widget.options.color.withValues(alpha: 0.1 + (_pulseAnimation.value - 0.1))
                      : widget.options.color.withValues(alpha: 0.1)),
            );
            return BarsView(
              options: widget.options,
              elements: elements,
            );
          }

          final elements = List.generate(
            samples.length,
            (i) => BarsViewItem(value: samples[i], color: widget.options.color),
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
