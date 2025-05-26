import 'package:audioplayers/audioplayers.dart';

class SoundEffects {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playOrderConfirmed() async {
    print('Playing order confirmed sound');
    await _player.play(AssetSource('sounds/confirm_order.wav'));
  }
}
