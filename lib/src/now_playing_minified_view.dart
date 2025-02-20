import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'audio/audio.dart';

class MusicPlayerStickySheet extends StatelessWidget {
  const MusicPlayerStickySheet({super.key, required AudioPlayer audioplayer})
    : _audioplayer = audioplayer;

  final AudioPlayer _audioplayer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0) + EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 4.0,
        children: [
          Row(
            spacing: 12.0,
            children: [
              Hero(
                tag: 'album_image',
                child: Container(
                  height: 60.0,
                  width: 60.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    image: DecorationImage(
                      image: AssetImage('assets/apt.jpg'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2.0,
                  children: [
                    Hero(
                      tag: 'song_name',
                      child: Text(
                        'A.P.T.(Rosie) Ft. Bruno Mars',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      'ROSE & Bruno Mars',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: AnimatedPlayPauseButton(size: 40.0),
              ),
            ],
          ),
          Hero(
            tag: 'play_pause_button',
            child: AudioPlayerSlider(
              audioPlayer: _audioplayer,
              builder: (context, current, total) {
                // log('current: $current, total: $total');
                return LinearProgressIndicator(
                  value: 0,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
