import 'package:flutter/material.dart';
import '../services/playlist_service.dart';
import '../models/youtube_track.dart';
import 'playlist_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlaylistService _playlistService = PlaylistService();
  Map<String, List<YouTubeTrack>> _playlists = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllPlaylists();
  }

  Future<void> _loadAllPlaylists() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final data = await _playlistService.loadPlaylists();
    if (!mounted) return;
    setState(() {
      _playlists = data;
      _isLoading = false;
    });
  }

  void _showCreatePlaylistDialog() {
    final TextEditingController _nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuova Playlist'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(hintText: 'Nome della playlist'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
          TextButton(
            onPressed: () async {
              if (_nameController.text.trim().isNotEmpty) {
                await _playlistService.createPlaylist(_nameController.text.trim());
                Navigator.pop(context);
                _loadAllPlaylists();
              }
            },
            child: const Text('Crea'),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePlaylist(String playlistName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Playlist'),
        content: Text('Sei sicuro di voler eliminare "$playlistName"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
          TextButton(
            onPressed: () async {
              await _playlistService.deletePlaylist(playlistName);
              Navigator.pop(context);
              _loadAllPlaylists();
            },
            child: const Text('Elimina', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('La tua Libreria'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _showCreatePlaylistDialog),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _playlists.isEmpty
          ? const Center(child: Text('Nessuna playlist creata. Clicca + per iniziare!'))
          : ListView.builder(
        itemCount: _playlists.keys.length,
        itemBuilder: (context, index) {
          final playlistName = _playlists.keys.elementAt(index);
          final trackCount = _playlists[playlistName]?.length ?? 0;
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(4)),
              child: const Icon(Icons.music_note, color: Colors.green),
            ),
            title: Text(playlistName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('$trackCount brani', style: const TextStyle(color: Colors.grey)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white30),
              onPressed: () => _confirmDeletePlaylist(playlistName),
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistDetailScreen(playlistName: playlistName),
                ),
              );
              if (mounted) _loadAllPlaylists();
            },
          );
        },
      ),
    );
  }
}