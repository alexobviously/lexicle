import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';
import 'package:word_game/extensions/ready_mixin.dart';

class SoundService with ReadyManager {
  Soundpool pool = Soundpool.fromOptions();
  Map<Sound, int> sounds = {};
  SoundService() {
    init();
  }

  Future<int> _load(String fileName) async {
    return await rootBundle.load('assets/sounds/$fileName').then((d) => pool.load(d));
  }

  @override
  void initialise() async {
    sounds[Sound.pop] = await _load('pop.wav');
    setReady();
  }

  void play(Sound sound) => pool.play(sounds[sound]!);
}

enum Sound {
  pop,
}
