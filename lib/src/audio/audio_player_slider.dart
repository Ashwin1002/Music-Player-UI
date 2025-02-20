import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

typedef SeekerBuilder =
    Widget Function(BuildContext context, Duration current, Duration total);

class AudioPlayerSlider extends StatefulWidget {
  const AudioPlayerSlider({super.key, this.audioPlayer, this.builder});

  final AudioPlayer? audioPlayer;
  final SeekerBuilder? builder;

  @override
  State<AudioPlayerSlider> createState() => _AudioPlayerSliderState();
}

class _AudioPlayerSliderState extends State<AudioPlayerSlider> {
  late final AudioPlayer _audioplayer;
  late final ValueNotifier<Duration> _progressNotifier;

  @override
  void initState() {
    super.initState();
    _audioplayer = widget.audioPlayer ?? AudioPlayer();
    if (widget.audioPlayer == null) {
      _audioplayer.setAsset(
        'assets/ROSE & Bruno Mars - APT. (Official Music Video).mp3',
      );
    }
    _progressNotifier = ValueNotifier<Duration>(Duration.zero);

    _audioplayer.positionStream.listen((duration) {
      log('duration => $duration');
      _progressNotifier.value = duration;
    });
  }

  @override
  void dispose() {
    _progressNotifier.dispose();
    if (widget.audioPlayer == null) _audioplayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // log('current position: ${_audioplayer.speedStream}');
    return ValueListenableBuilder<Duration>(
      valueListenable: _progressNotifier,
      builder: (context, duration, child) {
        log('current: $duration');
        return widget.builder?.call(
              context,
              duration,
              _audioplayer.duration ?? Duration.zero,
            ) ??
            const Placeholder();
      },
    );
  }
}
