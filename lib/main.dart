import 'dart:collection';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:midi_player/midi_player.dart';
import 'package:dart_midi/dart_midi.dart';
import 'package:url_launcher/url_launcher.dart';

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
  int _noteCounter = 0;
  List<List<NoteOnEvent>> _noteOnEvents = [];
  bool _secondButtonState = false;

  // Functions

  /// Play [note] on the piano at [velocity] (0 to 1.0, the maximum is used if omitted).
  void playNote({required int note, double velocity = 1.0}) {
    _midiPlayer.playNote(note: note - 0, velocity: velocity);
  }

  /// Open file dialog using [FilePicker] to select ONE midi file
  /// and return a sorted list of all [NoteOnEvent] from it.
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

  /// Open [www.musescore.com] in external web browser.
  Future<bool> launchMuseScore() async => await launchUrl(
        Uri.parse('https://musescore.com'),
        mode: LaunchMode.externalApplication,
      );

  // Functions (Overridden)

  @override
  void initState() {
    _midiPlayer.load('assets/midi/Steinway.sf2');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Test"),
        ),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  var result = await getMidiFile();
                  if (result != null) {
                    _noteOnEvents = result;
                    _noteCounter = 0;
                    setState(() => _secondButtonState = true);
                    launchMuseScore();
                  }
                },
                child: const Text("Load"),
              ),
              SizedBox(
                width: 500,
                height: 500,
                child: ElevatedButton(
                  onPressed: _secondButtonState
                      ? () {
                          for (final noteOnEvent
                              in _noteOnEvents[_noteCounter++]) {
                            playNote(note: noteOnEvent.noteNumber);
                            if (_noteCounter >= _noteOnEvents.length) {
                              setState(() => _secondButtonState = false);
                            }
                          }
                        }
                      : null,
                  child: const Text('Play'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
