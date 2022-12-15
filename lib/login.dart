import 'package:diame/operations/forgotpasswordpage.dart';
import 'package:diame/main.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';

class Login extends StatefulWidget {
  final VoidCallback onClickedSignUp;
  const Login({
    Key? key,
    required this.onClickedSignUp,
  }) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late bool _obscureText;
  late String error;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    _obscureText = true;
    error = '';
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void toastAlert(title) => Fluttertoast.showToast(
        msg: title,
        gravity: ToastGravity.TOP,
      );

  Widget logintext() => Column(
        children: [
          SizedBox(
            height: 140,
          ),
          Text(
            "dia.me",
            style: GoogleFonts.poppins(
              fontSize: 64,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              letterSpacing: 10,
            ),
          ),
        ],
      );
  Widget textWelcome() => Text(
        "Welcome Back",
        style: GoogleFonts.poppins(
          fontSize: 36,
          fontWeight: FontWeight.w500,
        ),
      );
  Widget textWelcomesub() => Text(
        "Login your account",
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w300,
        ),
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
  Widget textFieldPassword() => TextFormField(
        scrollPadding: const EdgeInsets.only(bottom: 50),
        controller: passwordController,
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
        style: GoogleFonts.poppins(),
        onChanged: (value) {
          // do something
        },
      );

  Widget textFields() => Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              textFieldEmail(),
              spacer(5.0),
              textFieldPassword(),
            ],
          ),
        ),
      );
  Widget loginButton() => SizedBox(
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
          onPressed: signIn,
        ),
      );
  Widget registerButton() => RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(
              color: Colors.black, fontWeight: FontWeight.w500),
          text: 'No Account? ',
          children: [
            TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = widget.onClickedSignUp,
              text: 'Register',
              style: GoogleFonts.poppins(
                decoration: TextDecoration.underline,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      );
  Widget forgotPassword() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ForgotPasswordPage(),
              ),
            ),
            child: Text(
              'Forgot Password?',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );

  Widget buttons() => Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loginButton(),
            SizedBox(height: 5),
            forgotPassword(),
            SizedBox(height: 10),
            registerButton(),
          ],
        ),
      );
  Widget divide() => const SizedBox(
        width: 300,
        child: Divider(
          color: Colors.black,
        ),
      );
  Widget spacer(height) => SizedBox(
        height: height,
      );
  Widget content() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          spacer(30.0),
          logintext(),
          divide(),
          textWelcome(),
          textWelcomesub(),
          spacer(20.0),
          textFields(),
          spacer(30.0),
          buttons(),
        ],
      );
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              content(),
            ],
          ),
        ),
      );
  Future signIn() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
                child: LoadingAnimationWidget.twistingDots(
              leftDotColor: Colors.black,
              rightDotColor: Colors.grey,
              size: 50,
            )));

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      snack('Loggin Successfully', Colors.green);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        snack("User not found", Colors.red);
        navigatorKey.currentState!.popUntil((route) => route.isFirst);
      } else if (e.code == 'wrong-password') {
        snack("Incorrect Password", Colors.red);
        navigatorKey.currentState!.popUntil((route) => route.isFirst);
      } else if (e.code == 'invalid-email') {
        snack("Incorrect Email", Colors.red);
        navigatorKey.currentState!.popUntil((route) => route.isFirst);
      } else if (e.code == 'unknown') {
        snack("Input Fields", Colors.red);
        navigatorKey.currentState!.popUntil((route) => route.isFirst);
      } else {}
    }
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
