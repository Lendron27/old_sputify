import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_controller.dart';

class MusicPlayerScreen extends StatelessWidget {
  const MusicPlayerScreen({Key? key}) : super(key: key);

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final audioController = Provider.of<AudioController>(context);
    final currentTrack = audioController.currentTrack;

    if (currentTrack == null) return const SizedBox.shrink();

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.music_video, size: 180, color: Colors.green),
          const SizedBox(height: 30),
          Text(currentTrack.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center), // 🟢 Corretto qui!
          Text(currentTrack.author, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 40),

          // Slider di progresso in tempo reale
          StreamBuilder<Duration>(
            stream: audioController.player.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final total = audioController.player.duration ?? Duration.zero;
              return Column(
                children: [
                  Slider(
                    activeColor: Colors.green,
                    inactiveColor: Colors.grey[800],
                    min: 0.0,
                    max: total.inMilliseconds.toDouble() > 0.0 ? total.inMilliseconds.toDouble() : 1.0,
                    value: position.inMilliseconds.toDouble().clamp(0.0, total.inMilliseconds.toDouble() > 0.0 ? total.inMilliseconds.toDouble() : 1.0),
                    onChanged: (value) => audioController.player.seek(Duration(milliseconds: value.toInt())),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(position), style: const TextStyle(color: Colors.grey)),
                      Text(_formatDuration(total), style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Controlli di riproduzione
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(icon: const Icon(Icons.skip_previous, size: 45), onPressed: audioController.isLoading ? null : audioController.skipPrevious),
              audioController.isLoading
                  ? const CircularProgressIndicator(color: Colors.green)
                  : StreamBuilder<bool>(
                stream: audioController.player.playingStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data ?? false;
                  return IconButton(
                    icon: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 70, color: Colors.white),
                    onPressed: () => playing ? audioController.player.pause() : audioController.player.play(),
                  );
                },
              ),
              IconButton(icon: const Icon(Icons.skip_next, size: 45), onPressed: audioController.isLoading ? null : audioController.skipNext),
            ],
          )
        ],
      ),
    );
  }
}