import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../globals.dart';

class Assignments extends StatefulWidget {
  const Assignments({Key? key, this.groupData}) : super(key: key);

  final groupData;

  @override
  State<Assignments> createState() => _AssignmentsState();
}

class _AssignmentsState extends State<Assignments> {
  var headerTextStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black);

  var textStyle =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    var verticalScale = screenHeight / mockUpHeight;
    var horizontalScale = screenWidth / mockUpWidth;

    return Scaffold(
      appBar: AppBar(
        title: Text('Assignments'),
      ),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                child: Center(
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Text(
                            "Sr. No",
                            style: headerTextStyle,
                          )),
                      Expanded(
                          flex: 1,
                          child: Text("Student Name", style: headerTextStyle)),
                      Expanded(
                          flex: 1,
                          child:
                              Text("Submitted file", style: headerTextStyle)),
                      Expanded(
                          flex: 1,
                          child: Text("Date of submission",
                              style: headerTextStyle)),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0 * verticalScale),
              child: Container(
                  width: screenWidth,
                  height: screenHeight * 0.4,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("assignment")
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            //timestamp conversion to date
                            Timestamp t = snapshot.data!.docs[index]
                                ["date of submission"];
                            DateTime date = t.toDate();
                            return Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Container(
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: Text("${index + 1}.",
                                            style: textStyle)),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                          snapshot.data!.docs[index]["name"],
                                          style: textStyle),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: InkWell(
                                        hoverColor: Colors.blueAccent,
                                        onTap: () {
                                          launch(snapshot.data!.docs[index]
                                              ["link"]);
                                        },
                                        child: Text(
                                            snapshot.data!.docs[index]
                                                ["filename"],
                                            style: textStyle),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            DateFormat('yyyy-MM-dd')
                                                .format(date),
                                            style: textStyle)),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return Container();
                    },
                  )),
            )
          ],
        ),
      ),
    );
  }
}
