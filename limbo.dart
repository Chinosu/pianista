import 'package:midi_player/midi_player.dart';

class Limbo {

  // notes:
  //  at least 21, at most 108
  static void playNote(MidiPlayer midiPlayer, int note, double velocity) =>
      midiPlayer.playNote(note: note + 21, velocity: velocity);
}
