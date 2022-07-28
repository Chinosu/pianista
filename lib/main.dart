import 'dart:collection';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:midi_player/midi_player.dart';
import 'package:dart_midi/dart_midi.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:just_audio/just_audio.dart';

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
  final _tempoPlayer = AudioPlayer();

  final List<List<NoteOnEvent>> _noteOnEvents = [];

  bool _secondButtonState = false;

  /// AnimatedList global key
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // Functions

  /// Play [note] on the piano at [velocity] (0 to 1.0, the maximum is used if omitted).
  void _playNote({required int note, double velocity = 1.0}) {
    _midiPlayer.playNote(note: note - 0, velocity: velocity);
  }

  /// Open file dialog using [FilePicker] to select ONE midi file
  /// and return a sorted list of all [NoteOnEvent] from it.
  Future<List<List<NoteOnEvent>>?> _getMidiFile() async {
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
      // Sort/Export map by key into list
      List<List<NoteOnEvent>> list = [];
      noteOnEvents.forEach((key, value) => list.add(value));

      // Sort sub-list by pitch/tone/note (high to low)
      for (var subList in list) {
        subList.sort((a, b) => b.noteNumber.compareTo(a.noteNumber));
      }

      return list;
    }
    return null;
  }

  /// Open [www.musescore.com] in external web browser.
  Future<bool> _launchMuseScore() async {
    return await launchUrl(
      Uri.parse('https://musescore.com'),
      mode: LaunchMode.externalApplication,
    );
  }

  /// Start the metronome according to the one of the five [tempo]
  void _startMetronome(String tempo) {
    _stopMetronome();
    switch (tempo) {
      case 'Adagio':
        _tempoPlayer.setAsset('assets/tempo/Adagio.mp3');
        break;
      case 'Andante':
        _tempoPlayer.setAsset('assets/tempo/Andante.mp3');
        break;
      case 'Moderato':
        _tempoPlayer.setAsset('assets/tempo/Moderato.mp3');
        break;
      case 'Vivace':
        _tempoPlayer.setAsset('assets/tempo/Vivace.mp3');
        break;
      case 'Presto':
        _tempoPlayer.setAsset('assets/tempo/Presto.mp3');
        break;
    }
    _tempoPlayer.play();
  }

  /// Stop the metronome
  void _stopMetronome() => _tempoPlayer.stop();

  /// Add to back-end [_noteOnEvents] AND notify front-end [_listKey]/[AnimatedList]
  void _addItemToList({required List<NoteOnEvent> element, int? index}) {
    index ??= _noteOnEvents.length;
    _noteOnEvents.insert(index, element);
    _listKey.currentState?.insertItem(index);
  }

  /// Remove from back-end [_noteOnEvents] AND notify front-end [_listKey]/[AnimatedList]
  void _removeItemFromList({int? index}) {
    index ??= _noteOnEvents.length - 1;
    final List<NoteOnEvent> removedElement = _noteOnEvents[index];
    _listKey.currentState?.removeItem(
        index, (context, animation) => _buildWidget(removedElement, animation));
    _noteOnEvents.removeAt(index);
  }

  /// Convert [List<NoteOnEvent>] to [List<Widget>]
  Widget _buildWidget(
      List<NoteOnEvent> removedElement, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      axis: Axis.horizontal,
      child: Card(
        child: SizedBox(
          height: 300,
          width: 100,
          child: ListTile(
            leading: ElevatedButton(
              onPressed: () {},
              child: Text('test'),
            ),
          ),
        ),
      ),
    );
  }

  // Functions (Overridden)

  @override
  void initState() {
    _midiPlayer.load('assets/midi/Steinway.sf2');
    _tempoPlayer.setLoopMode(LoopMode.one);
    _tempoPlayer.setVolume(0.2);
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
          child: FittedBox(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    var result = await _getMidiFile();
                    if (result != null) {
                      while (_noteOnEvents.isNotEmpty) {
                        _removeItemFromList();
                      }
                      for (var subResult in result) {
                        _addItemToList(element: subResult);
                      }
                      setState(() => _secondButtonState = true);
                    }
                  },
                  child: const Text("Load"),
                ),
                SizedBox(
                  height: 700,
                  width: 500,
                  child: AnimatedList(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    key: _listKey,
                    itemBuilder: (context, index, animation) =>
                        _buildWidget(_noteOnEvents[index], animation),
                  ),
                ),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: ElevatedButton(
                    onPressed: _secondButtonState
                        ? () {
                            for (final noteOnEvent in _noteOnEvents[0]) {
                              _playNote(note: noteOnEvent.noteNumber);
                            }
                            _removeItemFromList(index: 0);
                            if (_noteOnEvents.isEmpty) {
                              setState(() => _secondButtonState = false);
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
      ),
    );
  }
}
