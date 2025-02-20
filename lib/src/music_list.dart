import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'src.dart';

class MusicList extends StatefulWidget {
  const MusicList({super.key});

  @override
  State<MusicList> createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  late final AudioPlayer _audioplayer;

  @override
  void initState() {
    super.initState();
    _audioplayer = AudioPlayer();
    _audioplayer.setAsset(
      'assets/ROSE & Bruno Mars - APT. (Official Music Video).mp3',
    );

    _audioplayer.positionStream.listen((duration) {
      log('duration => $duration');
    });
  }

  @override
  void dispose() {
    _audioplayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: ListView.builder(
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    title: Text('Song $index'),
                    subtitle: Text('Artist Name $index'),
                    onTap: () {},
                    leading: Container(
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
                );
              },
            ),
          ),
          MusicPlayerDetailView(audioplayer: _audioplayer),
        ],
      ),
    );
  }
}
