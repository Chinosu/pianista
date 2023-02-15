import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:pianista/pianista.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        backgroundColor: Colors.black26,
        scaffoldBackgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.cyanAccent,
        ),
      ),
      home: const IntroductionPage(),
    ),
  );
}

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({Key? key}) : super(key: key);

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: '\n\n\n\n\n\n\n\nPianista',
          body: '\n\n\n\n\nTap load to select a midi file.\n\nTap the screen to play.\n\nTap high to play louder and tap lower to play softer.\n\nTap metronome to enable, disable, or configure.\n\nTap Get more midi files to download midi from www.musescore.com.',
        ),
      ],
      onDone: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Pianista()));
      },
      showBackButton: false,
      showSkipButton: false,
      skip: const Icon(Icons.skip_next),
      next: const Icon(Icons.navigate_next),
      done: const Text(
        'Done',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10),
        activeSize: const Size(20, 10),
        activeColor: Colors.blueAccent,
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }
}
