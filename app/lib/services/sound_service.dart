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
    sounds[Sound.clickUp] = await _load('up.wav');
    sounds[Sound.clickDown] = await _load('down.wav');
    sounds[Sound.good] = await _load('good.wav');
    sounds[Sound.bad] = await _load('bad.wav');
    setReady();
  }

  void play(Sound sound) => pool.play(sounds[sound]!);
}

enum Sound {
  pop,
  clickUp,
  clickDown,
  good,
  bad,
}
