import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/playlist_service.dart';
import '../models/youtube_track.dart';
import '../services/audio_controller.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistName;
  const PlaylistDetailScreen({Key? key, required this.playlistName}) : super(key: key);

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final PlaylistService _playlistService = PlaylistService();
  List<YouTubeTrack> _tracks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    setState(() => _isLoading = true);
    final playlists = await _playlistService.loadPlaylists();
    setState(() {
      _tracks = playlists[widget.playlistName] ?? [];
      _isLoading = false;
    });
  }

  void _removeTrack(String trackId) async {
    final updatedPlaylists = await _playlistService.removeTrackFromPlaylist(widget.playlistName, trackId);
    setState(() {
      _tracks = updatedPlaylists[widget.playlistName] ?? [];
    });
  }

  void _handlePlayAction(int index) {
    if (_tracks.isNotEmpty) {
      Provider.of<AudioController>(context, listen: false).playPlaylist(_tracks, index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.playlistName),
              background: Container(
                color: Colors.grey[850],
                child: const Icon(Icons.library_music, size: 80, color: Colors.green),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _handlePlayAction(0),
                    icon: const Icon(Icons.play_arrow, color: Colors.black),
                    label: const Text('PLAY', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: const StadiumBorder()),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final track = _tracks[index];
                return ListTile(
                  leading: const Icon(Icons.music_note, color: Colors.grey),
                  title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(track.author),
                  onTap: () => _handlePlayAction(index),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                    onPressed: () => _removeTrack(track.id),
                  ),
                );
              },
              childCount: _tracks.length,
            ),
          ),
        ],
      ),
    );
  }
}