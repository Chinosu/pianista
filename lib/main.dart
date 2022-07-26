import 'dart:collection';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:midi_player/midi_player.dart';
import 'package:dart_midi/dart_midi.dart';
import 'package:tuple/tuple.dart';

// flutter run --no-sound-null-safety

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

  /// Play [note] (0 to 87) on the piano at [velocity] (0 to 1.0, the maximum is used if omitted).
  void playNote({required int note, double velocity = 1.0}) {
    // MidiPlayer can play n if 21<=n<=108
    _midiPlayer.playNote(note: note + 21, velocity: velocity);
  }

  /// Open file dialog using [FilePicker] to select ONE midi file
  /// and return a sorted list of all [NoteOnEvent] from it
  Future<List<List<NoteOnEvent>>?> getMidiFile() async {
    // Open file browser dialog
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['midi'],
    );

    if (result != null) {
      MidiFile midiFile =
          MidiParser().parseMidiFromFile(File(result.files.single.path!));

      final SplayTreeMap<int, List<NoteOnEvent>> noteOnEvents =
          SplayTreeMap<int, List<NoteOnEvent>>();

      // For each track
      for (List<MidiEvent> track in midiFile.tracks) {
        // For each MidiEvent
        for (int i = 0; i < track.length; i++) {
          if (track[i] is NoteOnEvent) {
            int deltaTimeFromStart = track[i].deltaTime;

            // For each PRECEDING MidiEvent
            for (int j = 0; j < i; j++) {
              deltaTimeFromStart += track[j].deltaTime;
            }

            // Add NoteOnEvent to noteOnEvents
            if (noteOnEvents.containsKey(deltaTimeFromStart)) {
              noteOnEvents[deltaTimeFromStart]?.add(track[i] as NoteOnEvent);
            } else {
              noteOnEvents[deltaTimeFromStart] = [track[i] as NoteOnEvent];
            }
          }
        }
      }
      // List sorted by key
      List<List<NoteOnEvent>> list = [];
      noteOnEvents.forEach((key, value) => list.add(value));
      return list;
    }
    return null;
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
          onPressed: () async {
            var list = await getMidiFile();
            if (list != null) {
              for (var item in list) {
                for (var subitem in item) {
                  print(subitem.noteNumber);
                  print(subitem.velocity);
                }
              }
            }
          },
          child: const Text("Test"),
        ),
      ),
    );
  }
}
