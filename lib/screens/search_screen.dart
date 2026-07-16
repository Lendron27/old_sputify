import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/playlist_service.dart';
import '../services/audio_streaming_service.dart';
import '../models/youtube_track.dart';
import '../services/audio_controller.dart';

class MusicPlayerDemo extends StatefulWidget {
  const MusicPlayerDemo({Key? key}) : super(key: key);

  @override
  State<MusicPlayerDemo> createState() => _MusicPlayerDemoState();
}

class _MusicPlayerDemoState extends State<MusicPlayerDemo> {
  late AudioStreamingService _streamService;
  List<YouTubeTrack> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;
  final TextEditingController _searchController = TextEditingController();
  final PlaylistService _playlistService = PlaylistService();

  @override
  void initState() {
    super.initState();
    _streamService = AudioStreamingService();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _isSearching = true);
      final results = await _streamService.searchTracks(query.trim());
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    });
  }

  void _showActionMenu(YouTubeTrack track) async {
    final playlists = await _playlistService.loadPlaylists();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.queue_music, color: Colors.green),
            title: const Text('Aggiungi alla coda di riproduzione'),
            onTap: () {
              Provider.of<AudioController>(context, listen: false).addToQueue(track);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aggiunto alla coda!')));
            },
          ),
          const Divider(color: Colors.white24),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Aggiungi a una playlist:', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ...playlists.keys.map((playlistName) => ListTile(
            leading: const Icon(Icons.playlist_add),
            title: Text(playlistName),
            onTap: () async {
              await _playlistService.addTrackToPlaylist(playlistName, track);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Aggiunto a $playlistName')));
            },
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cerca')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Artisti, brani o podcast',
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator(color: Colors.green))
                  : _searchResults.isEmpty
                  ? const Center(child: Text('Nessun risultato. Inizia a digitare!', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final track = _searchResults[index];
                  return ListTile(
                    leading: const Icon(Icons.music_note, color: Colors.green),
                    title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(track.author),
                    onTap: () => Provider.of<AudioController>(context, listen: false).playSingleTrack(track),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () => _showActionMenu(track),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}