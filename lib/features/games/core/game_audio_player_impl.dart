import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'game_audio_player.dart';

class GameAudioPlayerImpl implements GameAudioPlayer {
  static const Duration _fallbackDuration = Duration(seconds: 4);

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Future<void> play(String lemmaId) async {
    await stop();
    try {
      await _audioPlayer.play(AssetSource('audio/$lemmaId.wav'));
    } catch (error) {
      throw GameAudioError(error.toString());
    }
  }

  @override
  Future<void> playAndWait(String lemmaId) async {
    await play(lemmaId);
    final completion = _audioPlayer.onPlayerComplete.first;
    try {
      await completion.timeout(_fallbackDuration);
    } on TimeoutException {}
  }

  @override
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  @override
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

class GameAudioError implements Exception {
  final String message;

  GameAudioError(this.message);

  @override
  String toString() => 'GameAudioError: $message';
}
