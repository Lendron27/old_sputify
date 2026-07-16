import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_controller.dart';
import 'home_screen.dart';
import 'search_screen.dart'; // 🟢 Punta alla tua schermata di ricerca
import 'music_player_screen.dart';

class MainNavigationHolder extends StatefulWidget {
  const MainNavigationHolder({Key? key}) : super(key: key);

  @override
  State<MainNavigationHolder> createState() => _MainNavigationHolderState();
}

class _MainNavigationHolderState extends State<MainNavigationHolder> {
  int _currentTabIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MusicPlayerDemo(), // 🟢 Corretto qui! Usiamo il nome esatto della tua classe di ricerca
  ];

  @override
  Widget build(BuildContext context) {
    final audioController = Provider.of<AudioController>(context);
    final currentTrack = audioController.currentTrack;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _currentTabIndex,
              children: _screens,
            ),
          ),
          // MINI PLAYER REATTIVO GLOBALE
          if (currentTrack != null)
            GestureDetector(
              onTap: () => _openFullPlayer(context),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(8),
                  border: Border(bottom: BorderSide(color: Colors.green.withOpacity(0.5), width: 2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.music_note, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(currentTrack.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(currentTrack.author, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    audioController.isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.green, strokeWidth: 2))
                        : StreamBuilder<bool>(
                      stream: audioController.player.playingStream,
                      builder: (context, snapshot) {
                        final playing = snapshot.data ?? false;
                        return IconButton(
                          icon: Icon(playing ? Icons.pause : Icons.play_arrow, color: Colors.white),
                          onPressed: () => playing ? audioController.player.pause() : audioController.player.play(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        backgroundColor: Colors.grey[950],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'La tua Libreria'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cerca'),
        ],
      ),
    );
  }

  void _openFullPlayer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[950],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => const MusicPlayerScreen(),
    );
  }
}