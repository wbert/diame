import 'package:awesome_calendar/awesome_calendar.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diame/landingpage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import 'createUser.dart';

class LogEditorEditor extends StatefulWidget {
  const LogEditorEditor({
    super.key,
    required this.user,
  });
  final User user;
  @override
  State<LogEditorEditor> createState() => _LogEditorEditorState();
}

class _LogEditorEditorState extends State<LogEditorEditor> {
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
    titleController = TextEditingController(text: widget.user.title);
    dateController = TextEditingController(
        text: "${widget.user.monthDate}\n${widget.user.year}");
    bodyController = TextEditingController(text: widget.user.body);
    monthDate = widget.user.monthDate;
    year = widget.user.year;
    dateTime = DateTime.now();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    titleController.dispose();
    // dateController.dispose();
    bodyController.dispose();
  }

  Widget fab() => FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () async {
          if (dateController.text == "") {
            snack("Date Empty", Colors.red);
          } else if (titleController.text == "") {
            snack("Title Empty", Colors.red);
          } else if (bodyController.text == "") {
            snack("Body Empty", Colors.red);
          } else {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.confirm,
              text: 'Are you sure to want to update this log?',
              showCancelBtn: true,
              confirmBtnText: 'Yes',
              confirmBtnColor: Colors.green,
              onCancelBtnTap: () => Navigator.pop(context),
              onConfirmBtnTap: () {
                update();
                int count = 0;
                Navigator.of(context).popUntil((_) => count++ >= 3);
                snack("Log Updated", Colors.green);
              },
            );
          }
        },
        child: const Icon(
          Icons.save,
          color: Colors.white,
        ),
      );
  Widget content() => Padding(
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
                  pickedDate = pickedDate;
                  monthDate =
                      "${monthCon[pickedDate.month - 1]} ${pickedDate.day.toString()}";
                  year = pickedDate.year.toString();
                  dateController.text = "$monthDate\n$year";
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
      );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          title: Text(
            'Edit Log',
            style: GoogleFonts.poppins(),
          ),
          centerTitle: true,
        ),
        body: ListView(
          children: [content()],
        ),
        floatingActionButton: fab());
  }

  void update() {
    final docUser =
        FirebaseFirestore.instance.collection('users').doc(widget.user.id);
    docUser.update({
      'monthDate': monthDate,
      'year': year,
      'title': titleController.text,
      'body': bodyController.text,
    });
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
