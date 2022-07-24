import 'package:flutter/material.dart';
import 'package:midi_player/midi_player.dart';
import 'package:pianista/limbo.dart';

void main() => runApp(const Pianista());

class Pianista extends StatefulWidget {
  const Pianista({Key? key}) : super(key: key);

  @override
  State<Pianista> createState() => _PianistaState();
}

class _PianistaState extends State<Pianista> {
  // Variables
  final MidiPlayer _midiPlayer = MidiPlayer();
  final int _noteCounter = 0;

  // Functions

  /// Plays [note] (0 to 87) on the piano at [velocity] (0 to 1.0, the maximum is used if omitted).
  void playNote({required int note, double velocity = 1.0}) {
    // MidiPlayer can play n if 21<=n<=108
    _midiPlayer.playNote(note: note + 21, velocity: velocity);
  }

  // Functions (Override)
  @override
  void initState() {
    _midiPlayer.load('assets/midi/Steinway.sf2');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Center(
        child: ElevatedButton(
          onPressed: () {
            // Test 1: Changing notes
            // playNote(note: _noteCounter++);

            // Test 2: Lowest note
            // playNote(note: 0);

            // Test 3: Highest note
            // playNote(note: 87);

            // Test 4: Impossible notes
            // playNote(note: -1);
            // playNote(note: 88);

            // ALl passed.
          },
          child: const Text("Test"),
        ),
      ),
    );
  }
}
