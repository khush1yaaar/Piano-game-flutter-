library piano_game;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'src/line.dart';
import 'src/line_divider.dart';
import 'src/note.dart';
import 'src/song_provider.dart';


class Piano extends StatefulWidget {
  @override
  _PianoState createState() => _PianoState();
}

class _PianoState extends State<Piano> with SingleTickerProviderStateMixin {
  final player = AudioPlayer();
  //final AudioCache player = AudioCache(prefix: 'music/');
  List<Note> notes = initNotes();
  late AnimationController animationController;
  int currentNoteIndex = 0;
  int points = 0;
  bool hasStarted = false;
  bool isPlaying = true;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && isPlaying) {
        if (notes[currentNoteIndex].state != NoteState.tapped) {
          //game over
          setState(() {
            isPlaying = false;
            notes[currentNoteIndex].state = NoteState.missed;
          });
          animationController.reverse().then((_) => _showFinishDialog());
        } else if (currentNoteIndex == notes.length - 5) {
          //song finished
          _showFinishDialog();
        } else {
          setState(() => ++currentNoteIndex);
          animationController.forward(from: 0);
        }
      }
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          Image.asset(
            'assets/images/background.jpg',
            fit: BoxFit.cover,
          ),
          Row(
            children: <Widget>[
              _drawLine(0),
              LineDivider(),
              _drawLine(1),
              LineDivider(),
              _drawLine(2),
              LineDivider(),
              _drawLine(3),
            ],
          ),
          _drawPoints(),
        ],
      ),
    );
  }

  void _restart() {
    setState(() {
      hasStarted = false;
      isPlaying = true;
      notes = initNotes();
      points = 0;
      currentNoteIndex = 0;
    });
    animationController.reset();
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Score: $points"),
          actions: <Widget>[
            FloatingActionButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("RESTART"),
            ),
          ],
        );
      },
    ).then((_) => _restart());
  }

  void _onTap(Note note) {
    bool areAllPreviousTapped = notes
        .sublist(0, note.orderNumber)
        .every((n) => n.state == NoteState.tapped);
    print(areAllPreviousTapped);
    if (areAllPreviousTapped) {
      if (!hasStarted) {
        setState(() => hasStarted = true);
        animationController.forward();
      }
      _playNote(note);
      setState(() {
        note.state = NoteState.tapped;
        ++points;
      });
    }
  }

  _drawLine(int lineNumber) {
    return Expanded(
      child: Line(
        lineNumber: lineNumber,
        currentNotes: notes.sublist(currentNoteIndex, currentNoteIndex + 5),
        onTileTap: _onTap,
        animation: animationController,
      ),
    );
  }

  _drawPoints() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: Text(
          "$points",
          style: const TextStyle(color: Colors.red, fontSize: 60),
        ),
      ),
    );
  }

  _playNote(Note note) async {
    switch (note.line) {
      case 0:
        await player.play(AssetSource('music/a.wav'));
        //player.play('music/a.wav' as Source);
        return;
      case 1:
        await player.play(AssetSource('music/c.wav'));
        //player.play('music/c.wav' as Source);
        return;
      case 2:
        await player.play(AssetSource('music/e.wav' ));
        //player.play('music/e.wav' as Source);
        return;
      case 3:
        await player.play(AssetSource('music/f.wav'));
        //player.play('music/f.wav' as Source);
        return;
    }
  }
}

