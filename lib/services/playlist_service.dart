import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/youtube_track.dart'; // Importa il modello locale invece di usare pacchetti esterni

class PlaylistService {
  static const String _storageKey = 'sputify_playlists';

  Future<Map<String, List<YouTubeTrack>>> loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);

    if (jsonString == null) return {};

    try {
      final Map<String, dynamic> decoded = json.decode(jsonString);
      Map<String, List<YouTubeTrack>> playlists = {};

      decoded.forEach((key, value) {
        final List<dynamic> trackList = value;
        playlists[key] = trackList.map((t) => YouTubeTrack.fromJson(t)).toList();
      });
      return playlists;
    } catch (e) {
      print("Errore nel caricamento delle playlist: $e");
      return {};
    }
  }

  Future<void> _savePlaylists(Map<String, List<YouTubeTrack>> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> toSave = {};

    playlists.forEach((key, value) {
      toSave[key] = value.map((t) => t.toJson()).toList();
    });

    await prefs.setString(_storageKey, json.encode(toSave));
  }

  Future<Map<String, List<YouTubeTrack>>> createPlaylist(String name) async {
    final playlists = await loadPlaylists();
    if (!playlists.containsKey(name)) {
      playlists[name] = [];
      await _savePlaylists(playlists);
    }
    return playlists;
  }

  Future<void> addTrackToPlaylist(String playlistName, YouTubeTrack track) async {
    final playlists = await loadPlaylists();
    if (playlists.containsKey(playlistName)) {
      if (!playlists[playlistName]!.any((t) => t.id == track.id)) {
        playlists[playlistName]!.add(track);
        await _savePlaylists(playlists);
      }
    }
  }

  Future<Map<String, List<YouTubeTrack>>> removeTrackFromPlaylist(String playlistName, String trackId) async {
    final playlists = await loadPlaylists();
    if (playlists.containsKey(playlistName)) {
      playlists[playlistName]!.removeWhere((t) => t.id == trackId);
      await _savePlaylists(playlists);
    }
    return playlists;
  }

  Future<Map<String, List<YouTubeTrack>>> deletePlaylist(String name) async {
    final playlists = await loadPlaylists();
    playlists.remove(name);
    await _savePlaylists(playlists);
    return playlists;
  }
}