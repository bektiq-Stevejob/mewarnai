import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final FlutterTts _tts = FlutterTts();
  bool isMuted = false;

  Future<void> init() async {
    try {
      await _tts.setLanguage('id-ID');
      await _tts.setPitch(1.3); // High, friendly kid tone
      await _tts.setSpeechRate(0.5);
    } catch (_) {}
  }

  void toggleMute() {
    isMuted = !isMuted;
    if (isMuted) {
      _tts.stop();
    }
  }

  Future<void> speakPraise(String text) async {
    if (isMuted) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }
}
