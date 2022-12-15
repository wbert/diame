import 'package:awesome_calendar/awesome_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diame/landingpage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import 'createUser.dart';

class LogEditor extends StatefulWidget {
  const LogEditor({
    super.key,
    required this.email,
    required this.uid,
  });
  final String email;
  final String uid;

  @override
  State<LogEditor> createState() => _LogEditorState();
}

class _LogEditorState extends State<LogEditor> {
  late TextEditingController titleController;
  late TextEditingController dateController;
  late TextEditingController bodyController;
  late DateTime dateTime;
  String monthDate = "";
  String year = "";

  var monthCon = [
    "January",
    "Febuary",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    titleController = TextEditingController();
    dateController = TextEditingController();
    bodyController = TextEditingController();
    dateTime = DateTime.now();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    titleController.dispose();
    dateController.dispose();
    bodyController.dispose();
  }

  Widget fab() => FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          if (dateController.text == "") {
            snack('Date Empty', Colors.red);
          } else if (titleController.text == "") {
            snack('Title Empty', Colors.red);
          } else if (bodyController.text == "") {
            snack('Body Empty', Colors.red);
          } else {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.confirm,
              text: 'Are you sure to want add new log?',
              showCancelBtn: true,
              confirmBtnText: 'Yes',
              confirmBtnColor: Colors.green,
              onCancelBtnTap: () => Navigator.pop(context),
              onConfirmBtnTap: () {
                createUser(
                  monthDate: monthDate,
                  year: year,
                  title: titleController.text,
                  body: bodyController.text,
                );

                int count = 0;
                Navigator.of(context).popUntil((_) => count++ >= 2);
                snack('Log Added', Colors.green);
              },
            );
          }
        },
        child: const Icon(
          Icons.save,
          color: Colors.white,
        ),
      );
  Widget content() => ListView(
        children: [
          Center(
              child: Text(
            "Add New Log",
            style: GoogleFonts.poppins(
                fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 5),
          )),
          const Divider(
            color: Colors.black,
            height: 10,
            indent: 35,
            endIndent: 35,
            thickness: 2,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.calendar_month),
                    hintText: 'Select Date',
                  ),
                  style: GoogleFonts.poppins(),
                  onTap: () async {
                    DateTime? pickedDate = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AwesomeCalendarDialog(
                          selectionMode: SelectionMode.single,
                          canToggleRangeSelection: true,
                        );
                      },
                    );

                    if (pickedDate != null) {
                      monthDate = monthCon[pickedDate.month - 1] +
                          " " +
                          pickedDate.day.toString();
                      year = pickedDate.year.toString();
                      //formatted date output using intl package =>  2021-03-16
                      setState(() {
                        dateController.text = "$monthDate\n$year";
                        //set output date to TextField value.
                      });
                    } else {}
                  },
                ),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Title',
                  ),
                  style: GoogleFonts.poppins(),
                  textAlign: TextAlign.center,
                ),
                TextField(
                  controller: bodyController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Type here...',
                  ),
                  style: GoogleFonts.poppins(),
                  textAlign: TextAlign.justify,
                  minLines: 10,
                  maxLines: 40,
                ),
              ],
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: content(),
      floatingActionButton: fab(),
    );
  }

  Future createUser({
    required String monthDate,
    required String year,
    required String title,
    required String body,
  }) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc();
    final user = User(
        id: docUser.id,
        uid: uid.toString(),
        monthDate: monthDate,
        year: year,
        title: title,
        body: body);
    final json = user.toJson();

    await docUser.set(json);
  }

  void snack(text, color) {
    var snackBar = SnackBar(
      content: Text(
        text,
        style: GoogleFonts.poppins(),
      ),
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
