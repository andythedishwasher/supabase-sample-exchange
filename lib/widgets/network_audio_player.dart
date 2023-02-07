import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class NetworkAudioPlayer extends StatefulWidget {
  const NetworkAudioPlayer(
      {super.key,
      required this.artist,
      required this.title,
      required this.url});

  final String artist;
  final String title;
  final String url;
  @override
  State<NetworkAudioPlayer> createState() => _NetworkAudioPlayerState();
}

class _NetworkAudioPlayerState extends State<NetworkAudioPlayer> {
  PlayerState _playerState = PlayerState.stopped;
  final AudioPlayer player = AudioPlayer();

  Future<void> assignUrl(url) async => {await player.setSourceUrl(url)};
  IconButton playButton() {
    switch (_playerState) {
      case PlayerState.playing:
        return IconButton(
            icon: const Icon(Icons.pause),
            onPressed: () async => {
                  await player.pause(),
                  setState(() => {_playerState = player.state})
                });
      case PlayerState.paused:
        return IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () async => {
                  await player.resume(),
                  setState(() => {_playerState = player.state})
                });
      case PlayerState.stopped:
        return IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () async => {
                  await player.resume(),
                  setState(() => {_playerState = player.state})
                });
      case PlayerState.completed:
        return IconButton(
          icon: const Icon(Icons.replay),
          onPressed: () async => {
            await player.seek(Duration.zero),
            await player.resume(),
            setState(() => {_playerState = player.state})
          },
        );
      default:
        return IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () => player.resume());
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      assignUrl(widget.url);
      player.onPlayerComplete.listen((event) {
        setState(() => {_playerState = PlayerState.completed});
      });
    });
    super.initState();
  }

  @override
  void dispose() async {
    await player.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.0,
      width: 300.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 10.0),
          playButton(),
          const SizedBox(width: 20.0),
          Text('${widget.artist} - ${widget.title}')
        ],
      ),
    );
  }
}
