import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'src.dart';

const _maxExtent = 1.0;
const _minExtent = 0.12;

const _collapseDuration = Duration(milliseconds: 100);
const _animationDuration = Duration(milliseconds: 250);

const _appbarHeight = 52.0;

const _imageSize = 220.0;
const _playPauseButtonSize = 60.0;

// We use a pixel threshold to normalize the scroll offset
const double _scrollThreshold = 300.0;

class MusicPlayerDetailView extends StatefulWidget {
  const MusicPlayerDetailView({super.key, this.audioplayer});

  final AudioPlayer? audioplayer;

  @override
  State<MusicPlayerDetailView> createState() => _MusicPlayerDetailViewState();
}

class _MusicPlayerDetailViewState extends State<MusicPlayerDetailView> {
  late final AudioPlayer _audioPlayer;
  late final DraggableScrollableController _controller;
  late final ScrollController _scrollController;

  final ValueNotifier<double> _scrollNotifier = ValueNotifier<double>(0);
  Timer? _dragStopTimer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = widget.audioplayer ?? AudioPlayer();
    _controller = DraggableScrollableController();

    Future.delayed(_animationDuration, () {
      _scrollNotifier.value = _maxExtent;
    });

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _controller.addListener(_onDragChangeListener);
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final normalized = (offset / _scrollThreshold).clamp(0.0, 1.0);
    _scrollNotifier.value = normalized;
    log('Scroll offset: $offset, normalized: $normalized');
  }

  void _onDragChangeListener() {
    final size = _controller.size;
    _scrollNotifier.value = size;

    // Cancel the previous timer to restart the detection
    _dragStopTimer?.cancel();

    // Use a slightly longer delay (e.g. 200ms)
    _dragStopTimer = Timer(_collapseDuration, () {
      log('Dragging stopped at size: $size');

      // Choose the target based on current size threshold
      if (size > 0.5) {
        _controller.animateTo(
          _maxExtent,
          duration: _animationDuration, // slightly faster animation
          curve: Curves.fastOutSlowIn,
        );
        log('Animating to MAX extent');
      } else {
        _controller.animateTo(
          _minExtent,
          duration: _animationDuration,
          curve: Curves.fastOutSlowIn,
        );
        log('Animating to MIN extent');
      }
    });
  }

  @override
  void dispose() {
    if (widget.audioplayer == null) _audioPlayer.dispose();
    _scrollNotifier.dispose();
    _dragStopTimer?.cancel();
    _controller
      ..removeListener(_onDragChangeListener)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log(
      'MediaQuery.viewInsetsOf(context).top: ${MediaQuery.viewPaddingOf(context).top}',
    );
    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: _maxExtent,
      shouldCloseOnMinExtent: false,
      maxChildSize: _maxExtent,
      minChildSize: _minExtent,
      builder: (context, scrollController) {
        return Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.only(
              // topLeft: Radius.circular(25),
              // topRight: Radius.circular(25),
            ),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              PinnedHeaderSliver(child: _buildStatusbarPadding()),
              PinnedHeaderSliver(child: _buildAppbar()),
              SliverToBoxAdapter(
                child: ScrollPercentListenableBuilder(
                  scrollNotifier: _scrollNotifier,
                  minExtent: _minExtent,
                  maxExtent: _maxExtent,
                  builder: (context, percent, _) {
                    return AnimatedSwitcher(
                      duration: _animationDuration,
                      child: Stack(
                        children: [
                          if (percent < .5)
                            Opacity(
                              opacity: 1 - percent,
                              child: MusicPlayerStickySheet(
                                key: ValueKey<String>(
                                  'Now playing collapsed view',
                                ),
                                audioplayer: _audioPlayer,
                              ),
                            ),

                          Opacity(
                            opacity: percent,
                            child: NowPlaying(
                              key: ValueKey<String>(
                                'Now playing extended view',
                              ),
                              percent: percent,
                              audioplayer: _audioPlayer,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppbar() {
    return ScrollPercentListenableBuilder(
      scrollNotifier: _scrollNotifier,
      maxExtent: _maxExtent,
      minExtent: _minExtent,
      builder: (context, percent, child) {
        log('percent: $percent');
        return AnimatedSwitcher(
          duration: _animationDuration,
          child:
              percent == 0
                  ? const SizedBox.shrink(
                    key: ValueKey<String>('hidden_appbar'),
                  )
                  : Opacity(
                    opacity: percent,
                    child: Container(
                      key: ValueKey<String>('visible_appbar'),
                      height: _appbarHeight * percent,
                      decoration: BoxDecoration(
                        color: Theme.of(context).canvasColor,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed:
                              () => _controller.animateTo(
                                _minExtent,
                                duration: _animationDuration,
                                curve: Curves.fastOutSlowIn,
                              ),
                          icon: Icon(Icons.keyboard_arrow_down),
                        ),
                      ),
                    ),
                  ),
        );
      },
    );
  }

  Widget _buildStatusbarPadding() {
    return ScrollPercentListenableBuilder(
      scrollNotifier: _scrollNotifier,
      maxExtent: _maxExtent,
      minExtent: _minExtent,
      builder: (context, percent, _) {
        return AnimatedContainer(
          key: ValueKey<String>('status-bar-padding'),
          duration: _animationDuration,
          child: Container(
            decoration: BoxDecoration(color: Theme.of(context).canvasColor),
            height: MediaQuery.viewPaddingOf(context).top * percent,
          ),
        );
      },
    );
  }
}

class NowPlaying extends StatelessWidget {
  const NowPlaying({super.key, required this.percent, this.audioplayer})
    : assert(percent >= 0 && percent <= 1);

  final double percent;
  final AudioPlayer? audioplayer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        spacing: 16.0,
        children: [
          Hero(
            tag: 'album_image',
            child: Image.asset(
              'assets/apt.jpg',
              height: _imageSize,
              width: _imageSize,
            ),
          ),
          Hero(
            tag: 'song_name',
            child: Text(
              'ROSE & Bruno Mars - APT. (Official Music Video).mp3',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 12.0,
            children: [
              IconButton(onPressed: () {}, icon: Icon(Icons.skip_previous)),
              Hero(
                tag: 'play_pause_button',
                child: AnimatedPlayPauseButton(
                  size: _playPauseButtonSize,
                  audioPlayer: audioplayer,
                ),
              ),
              IconButton(onPressed: () {}, icon: Icon(Icons.skip_next)),
            ],
          ),
          AudioPlayerSlider(
            audioPlayer: audioplayer,
            builder: (context, current, total) {
              return LinearProgressIndicator(
                value: 0.5,
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              );
            },
          ),
        ],
      ),
    );
  }
}
