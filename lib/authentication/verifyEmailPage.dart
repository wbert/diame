import 'dart:async';
import 'package:diame/landingpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;
  late String error;

  void toastAlert(title) => Fluttertoast.showToast(
        msg: title,
        gravity: ToastGravity.TOP,
      );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    error = "";

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } on Exception catch (e) {
      snack(e, Colors.red);
    }
  }

  Widget textVerifyMessage() => Text(
        'A verification email has \nsent to your email.',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          letterSpacing: 3,
        ),
        textAlign: TextAlign.center,
      );
  Widget verifyButton() => SizedBox(
        width: 300,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: const StadiumBorder(),
          ),
          child: Text(
            'Send Verification',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          onPressed: canResendEmail ? sendVerificationEmail : null,
        ),
      );
  Widget cancelButton() => SizedBox(
        width: 300,
        child: TextButton(
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(color: Colors.black),
          ),
          onPressed: () => FirebaseAuth.instance.signOut(),
        ),
      );

  Widget spacer(height) => SizedBox(
        height: height,
      );

  Widget content() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            spacer(280.0),
            textVerifyMessage(),
            spacer(30.0),
            verifyButton(),
            spacer(10.0),
            cancelButton(),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? Landingpage()
      : Scaffold(
          body: ListView(children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [content()],
            ),
          ]),
        );
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
}
