class YouTubeTrack {
  final String id;
  final String title;
  final String author;
  final String duration;
  String? streamUrl;

  YouTubeTrack({
    required this.id,
    required this.title,
    required this.author,
    required this.duration,
    this.streamUrl,
  });

  factory YouTubeTrack.fromJson(Map<String, dynamic> json) {
    return YouTubeTrack(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Titolo sconosciuto',
      author: json['author'] ?? 'Autore sconosciuto',
      duration: json['duration'] ?? '0:00',
      streamUrl: json['streamUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'duration': duration,
      'streamUrl': streamUrl,
    };
  }
}