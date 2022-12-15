import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diame/landingpage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class Profile extends StatefulWidget {
  const Profile({
    super.key,
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  String? email;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future uploadFile() async {
    final path = 'files/${pickedFile!.name}';
    final file = File(pickedFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);

    setState(() {
      uploadTask = ref.putFile(file);
    });

    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download Link: $urlDownload');
    updateProfile(urlDownload, uid);
    setState(() {
      uploadTask = null;
    });
  }

  Widget image() => StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('accounts')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.twistingDots(
                leftDotColor: Colors.black,
                rightDotColor: Colors.grey,
                size: 50,
              ),
            );
          }
          return Center(
              child: CircleAvatar(
            radius: 120,
            backgroundImage: NetworkImage(snapshot.data?['image']),
          ));
        } else {
          return const CircularProgressIndicator(
            color: Colors.black,
          );
        }
      });
  Widget info() => StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('accounts')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 24,
                  ),
                  Text(
                    'Email',
                    style: GoogleFonts.poppins(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      snapshot.data?['email'],
                      style: GoogleFonts.poppins(fontSize: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.fingerprint,
                    size: 24,
                  ),
                  Text(
                    'ID',
                    style: GoogleFonts.poppins(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    snapshot.data?['uid'],
                    style: GoogleFonts.poppins(fontSize: 20),
                  ),
                ],
              )
            ],
          );
        } else {
          return LoadingAnimationWidget.twistingDots(
            leftDotColor: Colors.black,
            rightDotColor: Colors.grey,
            size: 200,
          );
        }
      });
  Widget profileW() => Stack(
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(250), color: Colors.black),
            child: image(),
          ),
          Positioned(
            top: 135,
            right: 10,
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                border: Border.all(width: 5, color: Colors.white),
                borderRadius: BorderRadius.circular(100),
                color: Colors.black,
              ),
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  // selectFile().then((value) => );
                  selectFile().then((value) => QuickAlert.show(
                        context: context,
                        type: QuickAlertType.confirm,
                        text: 'Are you sure to want update your profile photo?',
                        showCancelBtn: true,
                        confirmBtnText: 'Yes',
                        confirmBtnColor: Colors.green,
                        onCancelBtnTap: () => Navigator.pop(context),
                        onConfirmBtnTap: () {
                          uploadFile();
                          int count = 0;
                          Navigator.of(context).popUntil((_) => count++ >= 1);
                        },
                      ));
                },
              ),
            ),
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20.0),
                Text(
                  'Profile',
                  style: GoogleFonts.poppins(
                      fontSize: 48,
                      letterSpacing: 10,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: profileW(),
                ),
                const SizedBox(
                  height: 32,
                ),
                const Divider(
                  color: Colors.black,
                  height: 10,
                  indent: 25,
                  endIndent: 25,
                  thickness: 3,
                ),
                const SizedBox(
                  height: 32,
                ),
                info(),
                const SizedBox(
                  height: 32,
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: const StadiumBorder(),
                  ),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Back',
                    style:
                        GoogleFonts.poppins(color: Colors.white, fontSize: 18),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;

          return SizedBox(
            height: 50,
            child: Stack(
              children: [
                Center(
                  child: CircularProgressIndicator.adaptive(
                    value: progress,
                    backgroundColor: Colors.grey,
                  ),
                ),
                Center(
                  child: Text(
                    '${(100 * progress).roundToDouble()}%',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          );
        } else {
          return const SizedBox(
            height: 50,
          );
        }
      });

  Future updateProfile(image, id) async {
    final docProfile =
        FirebaseFirestore.instance.collection('accounts').doc(id);
    docProfile.update({'image': image}).then(
        (value) => snack('Profile picture updated', Colors.green));
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
