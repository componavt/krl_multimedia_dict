abstract class GameAudioPlayer {
  Future<void> play(String lemmaId);
  Future<void> playAndWait(String lemmaId);
  Future<void> stop();
  Future<void> dispose();
}
