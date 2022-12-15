import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diame/logReader.dart';
import 'package:diame/operations/activity.dart';
import 'package:diame/operations/logeditor.dart';
import 'package:diame/notecard.dart';
import 'package:diame/operations/profile.dart';
import 'package:diame/operations/qoute.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class Landingpage extends StatefulWidget {
  Landingpage({super.key});

  @override
  State<Landingpage> createState() => _LandingpageState();
}

String? email = FirebaseAuth.instance.currentUser!.email.toString();
String? uid = FirebaseAuth.instance.currentUser!.uid.toString();

class _LandingpageState extends State<Landingpage> {
  late Future<Activity> futureActivity;
  late Future<Qoute> futureQoute;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureActivity = fetchActivity();
    futureQoute = fetchQoute();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future emailRefresh() async {
    //FirebaseAuth.instance.currentUser!.reload();
    email = FirebaseAuth.instance.currentUser!.email;
    uid = FirebaseAuth.instance.currentUser!.uid.toString();
  }

  String todo = "";

  Widget qoute() => FutureBuilder<Qoute>(
        future: futureQoute,
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(children: [
                    Text(
                      "'${snapshot.data!.content}'",
                      style: GoogleFonts.poppins(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "\n-${snapshot.data!.author}",
                          textAlign: TextAlign.end,
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ]),
                )
              ],
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          // By default, show a loading spinner.
          return LoadingAnimationWidget.twistingDots(
            leftDotColor: Colors.black,
            rightDotColor: Colors.grey,
            size: 10,
          );
        },
      );

  Widget album() => FutureBuilder<Activity>(
        future: futureActivity,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            Future(() {
              // Future Callback
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text(
                          'To do!',
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.bold),
                        ),
                        content: Text(
                          snapshot.data!.activity,
                          style: GoogleFonts.poppins(),
                        ),
                        actions: <Widget>[
                          Center(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: const StadiumBorder(),
                                ),
                                onPressed: (() {
                                  Navigator.pop(context);
                                }),
                                child: Text(
                                  'Dismiss',
                                  style:
                                      GoogleFonts.poppins(color: Colors.white),
                                )),
                          ),
                        ],
                      ));
            });
            return Container();
          }
        },
      );

  Widget searchAndMenuButton() => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    navDrawer();
                  });
                },
                icon: const Icon(
                  Icons.menu,
                  color: Colors.black,
                ),
              )
            ],
          ),
        ],
      );

  Widget fActionButton() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.black,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LogEditor(
                    email: email.toString(),
                    uid: uid.toString(),
                  ),
                ),
              );
            },
            child: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
          ),
        ],
      );

  Widget frontCard() => Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  );
                }
                if (snapshot.hasData) {
                  return GridView(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                    children: snapshot.data!.docs
                        .map((log) => noteCard(() {}, log))
                        .toList(),
                  );
                }
                return Center(
                  child: Text(
                    'theres no notes',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );

  Widget imgNotExist() => Image.asset(
        'assets/images/no-image.png',
        fit: BoxFit.cover,
      );

  Widget image() => StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('accounts')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Center(
              child: CircleAvatar(
            radius: 80,
            backgroundImage: NetworkImage(snapshot.data?['image']),
          ));
        } else {
          return CircularProgressIndicator();
        }
      });

  Widget l() => FutureBuilder(
        future: futureQoute,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Text(snapshot.data!.q);
        },
      );

  Widget navDrawer() => Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 300,
              child: DrawerHeader(
                child: Column(
                  children: [
                    image(),
                    SizedBox(height: 20),
                    const Divider(
                      color: Colors.white,
                      height: 10,
                      indent: 25,
                      endIndent: 25,
                      thickness: 1,
                    ),
                    Text(
                      'Logged in as',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Expanded(
                      child: Text(
                        email.toString(),
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.verified_user),
              title: Text(
                'Profile',
                style: GoogleFonts.poppins(color: Colors.black),
              ),
              onTap: () => {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Profile()))
              },
            ),
            ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: Text(
                  'Logout',
                  style: GoogleFonts.poppins(),
                ),
                onTap: () {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.confirm,
                    text: 'Are you sure to want to Logout?',
                    showCancelBtn: true,
                    confirmBtnText: 'Yes',
                    confirmBtnColor: Colors.green,
                    onCancelBtnTap: () => Navigator.pop(context),
                    onConfirmBtnTap: () {
                      FirebaseAuth.instance.signOut();
                      int count = 0;
                      Navigator.of(context).popUntil((_) => count++ >= 1);
                      snack("logged out successfully", Colors.green);
                    },
                  );
                }),
            SizedBox(
              height: 350,
              child: qoute(),
            ),
          ],
        ),
      );
  Widget card() => StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.twistingDots(
                leftDotColor: Colors.black,
                rightDotColor: Colors.grey,
                size: 50,
              ),
            );
          }
          if (snapshot.hasData) {
            return Wrap(
              // scrollDirection: Axis.vertical,
              // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              //     crossAxisCount: 2),
              children: snapshot.data!.docs
                  .map((log) => noteCard(() {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => LogReader(log))));
                      }, log))
                  .toList(),
            );
          }
          return Center(
            child: Text(
              'theres no notes',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    setState(() {
      emailRefresh();
    });
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: navDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        brightness: Brightness.dark,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemStatusBarContrastEnforced: true,
          systemNavigationBarColor: Colors.black,
        ),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: ScrollController(),
        child: Column(
          children: [
            Center(
                child: Text(
              "Daily Logs",
              style: GoogleFonts.poppins(
                  fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 5),
            )),
            const Divider(
              color: Colors.black,
              height: 10,
              indent: 25,
              endIndent: 25,
              thickness: 3,
            ),
            card(),
            album(),
          ],
        ),
      ),
      floatingActionButton: fActionButton(),
    );
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

  Future<Activity> fetchActivity() async {
    final response =
        await http.get(Uri.parse('https://www.boredapi.com/api/activity'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Activity.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  Future<Qoute> fetchQoute() async {
    final response = await http.get(Uri.parse(
        'https://api.quotable.io/random?tags=technology,famous-quotes'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      return Qoute.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }
}
