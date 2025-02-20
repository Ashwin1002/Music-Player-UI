import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AnimatedPlayPauseButton extends StatefulWidget {
  const AnimatedPlayPauseButton({super.key, this.size, this.audioPlayer});

  final AudioPlayer? audioPlayer;
  final double? size;

  @override
  State<AnimatedPlayPauseButton> createState() =>
      _AnimatedPlayPauseButtonState();
}

class _AnimatedPlayPauseButtonState extends State<AnimatedPlayPauseButton>
    with SingleTickerProviderStateMixin {
  late final AudioPlayer _audioplayer;
  late final AnimationController _animationController;
  late final Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _iconAnimation = CurvedAnimation(
      curve: Curves.decelerate,
      parent: _animationController,
    );
    _audioplayer = widget.audioPlayer ?? AudioPlayer();
    if (widget.audioPlayer == null) {
      _audioplayer.setAsset(
        'assets/ROSE & Bruno Mars - APT. (Official Music Video).mp3',
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (widget.audioPlayer == null) _audioplayer.dispose();
    super.dispose();
  }

  void _playPause() {
    if (_audioplayer.playing) {
      _audioplayer.pause();
      _animationController.reverse();
    } else {
      _audioplayer.play();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _playPause,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, _) {
          return AnimatedIcon(
            icon: AnimatedIcons.play_pause,
            progress: _iconAnimation,
            size: widget.size,
            semanticLabel: _audioplayer.playing ? 'Pause' : 'Play',
          );
        },
      ),
    );
  }
}
