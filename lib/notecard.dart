import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget noteCard(Function()? onTap, QueryDocumentSnapshot doc) {
  return InkWell(
      onTap: onTap,
      child: Container(
        height: 160,
        width: 160,
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    doc["monthDate"],
                    style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 9),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  doc["year"],
                  style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 9),
                  textAlign: TextAlign.end,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              doc["title"],
              style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 9),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Text(
                doc["body"],
                style: GoogleFonts.poppins(color: Colors.black, fontSize: 9),
                maxLines: 6,
                overflow: TextOverflow.fade,
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ));
}
