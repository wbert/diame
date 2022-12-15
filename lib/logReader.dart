import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diame/operations/createUser.dart';
import 'package:diame/operations/logeditoredit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class LogReader extends StatefulWidget {
  LogReader(this.doc, {Key? key}) : super(key: key);

  QueryDocumentSnapshot doc;

  @override
  State<LogReader> createState() => _LogReaderState();
}

class _LogReaderState extends State<LogReader> {
  final FlutterTts flutterTts = FlutterTts();
  late bool speakState;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    speakState = false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    speak(msg) async {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1);
      await flutterTts.speak(msg);
    }

    shut() async {
      await flutterTts.stop();
    }

    Widget fabs() => Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LogEditorEditor(
                      user: User(
                        id: widget.doc['id'],
                        monthDate: widget.doc['monthDate'],
                        year: widget.doc['year'],
                        title: widget.doc['title'],
                        body: widget.doc['body'],
                      ),
                    ),
                  ),
                );
              },
              child: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: () {
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.warning,
                  text: 'Are you sure to want to delete this log?',
                  showCancelBtn: true,
                  confirmBtnText: 'Yes',
                  confirmBtnColor: Colors.red,
                  onCancelBtnTap: () => Navigator.pop(context),
                  onConfirmBtnTap: () {
                    delete();
                    int count = 0;
                    Navigator.of(context).popUntil((_) => count++ >= 1);
                    snack("Log Deleted Successfully", Colors.green);
                  },
                );
              },
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            FloatingActionButton(
              tooltip: 'Speak',
              backgroundColor: Colors.black,
              onPressed: () {
                setState(() {
                  speakState = !speakState;
                });
                (speakState == true)
                    ? speak(
                        "${widget.doc['monthDate']},${widget.doc['year']}, ${widget.doc['title']}, ${widget.doc['body']}")
                    : shut();
              },
              child: const Icon(
                Icons.volume_up,
                color: Colors.white,
              ),
            ),
          ],
        );
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.doc["monthDate"],
                        style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 32),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.doc["year"],
                        style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 28),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Text(
                    widget.doc["title"],
                    style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 24),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.doc["body"],
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.fade,
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: fabs());
  }

  void snack(text, color) {
    var snackBar = SnackBar(
      content: Text(
        text,
        style: GoogleFonts.poppins(),
      ),
      backgroundColor: color,
    );
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void delete() {
    final docUser =
        FirebaseFirestore.instance.collection('users').doc(widget.doc['id']);
    docUser.delete();
    Navigator.pop(context);
  }
}
