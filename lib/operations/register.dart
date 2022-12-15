import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diame/main.dart';
import 'package:diame/operations/createProfile.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';

class Register extends StatefulWidget {
  final Function() onClickedSignIn;
  const Register({
    Key? key,
    required this.onClickedSignIn,
  }) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController passwordController1;
  late TextEditingController emailController;
  late bool _obscureText;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    passwordController1 = TextEditingController();
    _obscureText = true;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordController1.dispose();
  }

  void toastAlert(title) => Fluttertoast.showToast(
        msg: title,
        gravity: ToastGravity.TOP,
      );

  Widget pagetitle() => Text(
        "Register",
        style: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 3,
        ),
      );
  Widget pagesubtitle() => Text(
        "Fill out the Form",
        style: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w400,
        ),
      );

  Widget textFieldEmail() => TextFormField(
        controller: emailController,
        style: GoogleFonts.poppins(),
        obscureText: false,
        decoration: InputDecoration(
            filled: false,
            fillColor: Colors.white,
            hintText: "Enter Email",
            contentPadding: const EdgeInsets.all(15),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(30))),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (email) => email != null && !EmailValidator.validate(email)
            ? 'Enter a valid Email'
            : null,
        onChanged: (value) {
          // do something
        },
      );
  Widget textFieldPassword() => TextFormField(
        controller: passwordController,
        style: GoogleFonts.poppins(),
        obscureText: _obscureText,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(15),
          filled: true,
          fillColor: Colors.white,
          hintText: "Password",
          hintStyle: GoogleFonts.poppins(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(Icons.remove_red_eye),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) => value != null && value.length < 6
            ? 'Enter min. 6 characters'
            : null,
        onChanged: (value) {
          // do something
        },
      );
  Widget textFieldConfirmPassword() => TextFormField(
        controller: passwordController1,
        style: GoogleFonts.poppins(),
        obscureText: true,
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "Confirm Password",
            contentPadding: const EdgeInsets.all(15),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(30))),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) => value != null && value != passwordController.text
            ? 'Password not matched'
            : null,
        onChanged: (value) {
          // do something
        },
      );
  Widget spacer(height) => SizedBox(
        height: height,
      );
  Widget divide(width) => SizedBox(
        width: width,
        child: const Divider(color: Colors.black),
      );
  Widget registerbutton() => SizedBox(
        width: 300,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: const StadiumBorder(),
          ),
          child: Text(
            'Register',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          onPressed: () {
            if (emailController.text == "") {
              snack("Empty Email", Colors.red);
            } else if (passwordController.text == "") {
              snack("Empty Password", Colors.red);
            } else if (passwordController1.text != passwordController.text) {
              snack("Password not Matched", Colors.red);
            } else {
              signUp();
            }
          },
        ),
      );
  Widget form() => Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            spacer(20.0),
            textFieldEmail(),
            spacer(10.0),
            textFieldPassword(),
            spacer(10.0),
            textFieldConfirmPassword(),
          ],
        ),
      );

  Widget content() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          spacer(110.0),
          pagetitle(),
          pagesubtitle(),
          divide(325.0),
          form(),
          spacer(55.0),
          registerbutton()
        ],
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ListView(
          scrollDirection: Axis.vertical,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: content(),
            ),
          ],
        ),
      );

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

  Future signUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Colors.black,
        ),
      ),
    );
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      String? uid = FirebaseAuth.instance.currentUser!.uid.toString();

      final docUser =
          FirebaseFirestore.instance.collection('accounts').doc(uid);
      final profile = CreateProfile(
          email: emailController.text.trim(),
          uid: FirebaseAuth.instance.currentUser!.uid.toString(),
          image:
              "https://firebasestorage.googleapis.com/v0/b/dia-me-9013e.appspot.com/o/files%2Fblank-profile-picture-ge228599bc_640.png?alt=media&token=54e69ca6-febd-4d9e-aad4-96b9296d634b");
      final json = profile.toJson();

      await docUser.set(json);
    } on FirebaseAuthException catch (e) {
      snack(e, Colors.red);
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    }
  }
}
