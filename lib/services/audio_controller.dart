import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/youtube_track.dart';
import 'audio_streaming_service.dart';

class AudioController extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final AudioStreamingService _streamingService = AudioStreamingService();

  List<YouTubeTrack> _queue = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  String? _currentLoadingTrackId;

  AudioPlayer get player => _player;
  List<YouTubeTrack> get queue => _queue;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;

  YouTubeTrack? get currentTrack =>
      (_queue.isNotEmpty && _currentIndex >= 0 && _currentIndex < _queue.length)
          ? _queue[_currentIndex]
          : null;

  AudioController() {
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        skipNext();
      }
    });
  }

  Future<void> playPlaylist(List<YouTubeTrack> tracks, int startIndex) async {
    if (tracks.isEmpty || startIndex < 0 || startIndex >= tracks.length) return;
    _queue = List.from(tracks);
    _currentIndex = startIndex;
    notifyListeners();
    await _loadTrackAndPlay(_currentIndex);
  }

  Future<void> playSingleTrack(YouTubeTrack track) async {
    _queue = [track];
    _currentIndex = 0;
    notifyListeners();
    await _loadTrackAndPlay(0);
  }

  void addToQueue(YouTubeTrack track) {
    _queue.add(track);
    notifyListeners();
  }

  Future<void> _loadTrackAndPlay(int index) async {
    if (_queue.isEmpty || index >= _queue.length || index < 0) return;
    final track = _queue[index];

    if (_currentLoadingTrackId == track.id && _isLoading) return;

    _isLoading = true;
    _currentLoadingTrackId = track.id;
    notifyListeners();

    try {
      String? url = track.streamUrl;
      if (url == null) {
        url = await _streamingService.getAudioStreamUrlFromId(track.id);
        if (url != null) track.streamUrl = url;
      }

      if (_currentLoadingTrackId != track.id) return;

      if (url != null) {
        await _player.setUrl(url, initialPosition: Duration.zero);
        if (_currentLoadingTrackId == track.id) {
          _player.play();
        }
      }
    } catch (e) {
      print("Errore riproduzione: $e");
    } finally {
      if (_currentLoadingTrackId == track.id) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void skipNext() {
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
      notifyListeners();
      _loadTrackAndPlay(_currentIndex);
    }
  }

  void skipPrevious() {
    if (_player.position.inSeconds > 3) {
      _player.seek(Duration.zero);
    } else if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
      _loadTrackAndPlay(_currentIndex);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}