import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// Una semplice classe per mappare i risultati della ricerca
class YouTubeTrack {
  final String id;
  final String title;
  final String author;
  String? streamUrl; // <- Aggiungi questo campo mutabile

  YouTubeTrack({required this.id, required this.title, required this.author, this.streamUrl});

  // Converte una canzone in una mappa (JSON) per poterla salvare sul telefono
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'streamUrl': streamUrl,
    };
  }

  // Ricrea una canzone partendo dai dati salvati sul telefono
  factory YouTubeTrack.fromJson(Map<String, dynamic> json) {
    final track = YouTubeTrack(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
    );
    track.streamUrl = json['streamUrl'];
    return track;
  }
}

class AudioStreamingService {
  final YoutubeExplode _yt = YoutubeExplode();

  /// FASE 1: Cerca su YouTube e restituisce i primi 8 risultati
  Future<List<YouTubeTrack>> searchTracks(String query) async {
    try {
      print('🔍 Ricerca parziale su YouTube per: $query');
      final searchResult = await _yt.search.search(query);

      // Prendiamo i primi 8 video trovati e li mappiamo
      return searchResult.take(8).map((video) {
        return YouTubeTrack(
          id: video.id.value,
          title: video.title,
          author: video.author,
        );
      }).toList();
    } catch (e) {
      print('❌ Errore durante la ricerca: $e');
      return [];
    }
  }

  /// FASE 2: Dato l'ID di un video specifico, estrae l'URL dello stream audio
  Future<String?> getAudioStreamUrlFromId(String videoId) async {
    try {
      print('📡 Estrazione stream per ID: $videoId');
      final manifest = await _yt.videos.streams.getManifest(videoId);

      final muxedStreams = manifest.muxed.toList();
      if (muxedStreams.isEmpty) return null;

      // Ordina per risoluzione crescente (qualità video minima = meno banda, stesso audio)
      muxedStreams.sort((a, b) => a.videoResolution.compareTo(b.videoResolution));

      print('🎵 Stream generato con successo! ✅');
      return muxedStreams.first.url.toString();
    } catch (e) {
      print('❌ Errore estrazione stream: $e');
      return null;
    }
  }

  void dispose() {
    _yt.close();
  }
}