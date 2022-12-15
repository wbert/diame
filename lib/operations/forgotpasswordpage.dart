import 'package:diame/main.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
  }

  void toastAlert(title) => Fluttertoast.showToast(
        msg: title,
        gravity: ToastGravity.TOP,
      );
  Widget text() => Text(
        'Recieve and email to \nreset your Password',
        style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w500),
      );

  Widget spacer(height) => SizedBox(
        height: height,
      );
  Widget textFieldEmail() => TextFormField(
        controller: emailController,
        obscureText: false,
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "Email",
            contentPadding: const EdgeInsets.all(15),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(30))),
        style: GoogleFonts.poppins(),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (email) => email != null && !EmailValidator.validate(email)
            ? 'Enter a valid Email'
            : null,
        onChanged: (value) {
          // do something
        },
      );
  Widget resetPasswordButton() => SizedBox(
        width: 300,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: const StadiumBorder(),
          ),
          child: Text(
            'Login',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          onPressed: resetPassword,
        ),
      );

  Widget Content() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          spacer(230.0),
          text(),
          spacer(20.0),
          textFieldEmail(),
          spacer(30.0),
          resetPasswordButton(),
        ],
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ListView(
          scrollDirection: Axis.vertical,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Content()],
                ),
              ),
            ),
          ],
        ),
      );

  Future resetPassword() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      toastAlert('Password Reset Email Sent');
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        toastAlert('No user found for that email.');
        Navigator.of(context).pop();
      } else if (e.code == 'invalid-email') {
        toastAlert('Invalid Email');
        Navigator.of(context).pop();
      }
    }
  }
}
