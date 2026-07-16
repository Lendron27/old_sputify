import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/audio_controller.dart';
import 'screens/main_navigation_holder.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AudioController(),
      child: const SpotifyCloneApp(),
    ),
  );
}

class SpotifyCloneApp extends StatelessWidget {
  const SpotifyCloneApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[900],
        primaryColor: Colors.green,
      ),
      home: const MainNavigationHolder(),
    );
  }
}