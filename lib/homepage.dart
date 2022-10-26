// ignore: import_of_legacy_library_into_null_safe
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/Providers/UserProvider.dart';
import 'package:cloudyml_app2/api/firebase_api.dart';
import 'package:cloudyml_app2/catalogue_screen.dart';
import 'package:cloudyml_app2/combo/combo_store.dart';
import 'package:cloudyml_app2/home.dart';
import 'package:cloudyml_app2/models/course_details.dart';
import 'package:cloudyml_app2/pages/notificationpage.dart';
import 'package:cloudyml_app2/store.dart';
import 'package:flutter/material.dart';
import 'package:cloudyml_app2/fun.dart';
import 'package:cloudyml_app2/models/firebase_file.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:cloudyml_app2/globals.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:badges/badges.dart';
import 'package:video_player/video_player.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<FirebaseFile>> futureFiles;
  List<Icon> list = [];

  late ScrollController _controller;
  final notificationBox = Hive.box('NotificationBox');

  showNotification() async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    if (notificationBox.isEmpty) {
      notificationBox.put(1, {"count": 0});
      provider
          .showNotificationHomeScreen(notificationBox.values.first["count"]);
    } else {
      provider
          .showNotificationHomeScreen(notificationBox.values.first["count"]);
    }
  }

  @override
  void initState() {
    showNotification();
    _controller = ScrollController();
    super.initState();
    futureFiles = FirebaseApi.listAll('reviews/');
  }

  @override
  Widget build(BuildContext context) {
    final providerNotification =
        Provider.of<UserProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    List<CourseDetails> course = Provider.of<List<CourseDetails>>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    var verticalScale = screenHeight / mockUpHeight;
    var horizontalScale = screenWidth / mockUpWidth;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: screenWidth,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Color.fromRGBO(
                        0,
                        0,
                        0,
                        0.35,
                      ),
                      offset: Offset(5, 5),
                      blurRadius: 52)
                ],
              ),
              child: Stack(
                children: [
                  Container(
                    width: 414 * horizontalScale,
                    height: 280 * verticalScale,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      image: DecorationImage(
                        alignment: Alignment.center,
                        image: AssetImage('assets/HomeImage.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Positioned(
                      top: 30 * verticalScale,
                      left: 10 * horizontalScale,
                      child: Container(
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Scaffold.of(context).openDrawer();
                              },
                              icon: Icon(
                                Icons.menu,
                                size: 30 * min(horizontalScale, verticalScale),
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              width: 10 * horizontalScale,
                            ),
                            Text(
                              'Home',
                              textScaleFactor:
                                  min(horizontalScale, verticalScale),
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )
                          ],
                        ),
                      )),
                  Positioned(
                      top: 31 * verticalScale,
                      right: 2 * horizontalScale,
                      child: Consumer<UserProvider>(
                        builder: (context, data, child) {
                          return StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection("Notifications")
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                print("-------------${notificationBox.values}");
                                if (snapshot.data!.docs.length <
                                    data.countNotification) {
                                  notificationBox.put(1,
                                      {"count": (snapshot.data!.docs.length)});
                                  providerNotification
                                      .showNotificationHomeScreen(
                                          notificationBox
                                              .values.first["count"]);
                                }
                                return Badge(
                                  showBadge: data.countNotification ==
                                              snapshot.data!.docs.length ||
                                          snapshot.data!.docs.length <
                                              data.countNotification
                                      ? false
                                      : true,
                                  child: IconButton(
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                NotificationPage()),
                                      );
                                      await notificationBox.put(1, {
                                        "count": (snapshot.data!.docs.length)
                                      });
                                      await providerNotification
                                          .showNotificationHomeScreen(
                                              notificationBox
                                                  .values.first["count"]);
                                      print(
                                          "++++++++++++++++++++++++${notificationBox.values}");
                                    },
                                    icon: Icon(
                                      Icons.notifications_active,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                  badgeColor: Colors.red,
                                  toAnimate: false,
                                  badgeContent: Text(
                                    snapshot.data!.docs.length -
                                                notificationBox
                                                    .values.first["count"] >=
                                            0
                                        ? (snapshot.data!.docs.length -
                                                notificationBox
                                                    .values.first["count"])
                                            .toString()
                                        : (notificationBox
                                                    .values.first["count"] -
                                                snapshot.data!.docs.length)
                                            .toString(),
                                    style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  position: BadgePosition(
                                    top: (2 -
                                            2 *
                                                (snapshot.data!.docs.length)
                                                    .toString()
                                                    .length) *
                                        verticalScale,
                                    end: data.countNotification >= 100 ? 2 : 7,
                                    // (7+((snapshot.data!.docs.length).toString().length))
                                  ),
                                );
                              });
                        },
                      )),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 5 * horizontalScale,
                top: 20 * verticalScale,
              ),
              child: Text(
                'Feature Courses',
                textScaleFactor: min(horizontalScale, verticalScale),
                style: TextStyle(
                  color: Color.fromRGBO(0, 0, 0, 1),
                  fontFamily: 'Poppins',
                  fontSize: 23,
                  letterSpacing:
                      0 /*percentages not used in flutter. defaulting to zero*/,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              width: screenWidth,
              height: 430 * verticalScale,
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                removeLeft: true,
                removeRight: true,
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: course.length,
                  itemBuilder: (BuildContext context, index) {
                    if (course[index].FcSerialNumber != '') {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            courseId = course[index].courseDocumentId;
                          });

                          print(courseId);
                          if (course[index].isItComboCourse) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ComboStore(
                                  courses: course[index].courses,
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const CatelogueScreen()),
                            );
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 15,
                            right: 15,
                            top: 15,
                          ),
                          child: Container(
                            width: 366 * horizontalScale,
                            height: 122 * verticalScale,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromRGBO(31, 31, 31, 0.2),
                                    offset: Offset(0, 10),
                                    blurRadius: 20)
                              ],
                              color: Color.fromRGBO(255, 255, 255, 1),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 5,
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: CachedNetworkImage(
                                    imageUrl: course[index].courseImageUrl,
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                    fit: BoxFit.fill,
                                    height: 100 * verticalScale,
                                    width: 127 * horizontalScale,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10 * verticalScale,
                                    ),
                                    Container(
                                      width: 194,
                                      child: Text(
                                        course[index].courseName,
                                        textScaleFactor:
                                            min(horizontalScale, verticalScale),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Color.fromRGBO(0, 0, 0, 1),
                                          fontFamily: 'Poppins',
                                          fontSize: 18,
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.bold,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20 * verticalScale,
                                    ),
                                    Image.asset(
                                      'assets/Rating.png',
                                      fit: BoxFit.fill,
                                      height: 11,
                                      width: 71,
                                    ),
                                    SizedBox(
                                      height: 20 * verticalScale,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'English  ||  ${course[index].numOfVideos} Videos',
                                          textAlign: TextAlign.left,
                                          textScaleFactor: min(
                                              horizontalScale, verticalScale),
                                          style: TextStyle(
                                              color:
                                                  Color.fromRGBO(88, 88, 88, 1),
                                              fontFamily: 'Poppins',
                                              fontSize: 12,
                                              letterSpacing:
                                                  0 /*percentages not used in flutter. defaulting to zero*/,
                                              fontWeight: FontWeight.normal,
                                              height: 1),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Text(
                                          course[index].coursePrice,
                                          textScaleFactor: min(
                                              horizontalScale, verticalScale),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Color.fromRGBO(
                                                  155, 117, 237, 1),
                                              fontFamily: 'Poppins',
                                              fontSize: 18,
                                              letterSpacing:
                                                  0 /*percentages not used in flutter. defaulting to zero*/,
                                              fontWeight: FontWeight.bold,
                                              height: 1),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 10,
                top: 10,
              ),
              child: Text(
                'Success Stories',
                textScaleFactor: min(horizontalScale, verticalScale),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 1),
                    fontFamily: 'Poppins',
                    fontSize: 23,
                    letterSpacing:
                        0 /*percentages not used in flutter. defaulting to zero*/,
                    fontWeight: FontWeight.bold,
                    height: 1),
              ),
            ),
            Container(
              height: screenHeight * 0.81 * verticalScale,
              width: screenWidth,
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: FutureBuilder<List<FirebaseFile>>(
                future: futureFiles,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());
                    default:
                      if (snapshot.hasError) {
                        return Center(
                            child: Text(
                          'Some error occurred!',
                          textScaleFactor: min(horizontalScale, verticalScale),
                        ));
                      } else {
                        final files = snapshot.data!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: GridView.builder(
                                scrollDirection: Axis.vertical,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: files.length,
                                itemBuilder: (context, index) {
                                  final file = files[index];

                                  return buildFile(context, file);
                                },
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 1,
                                        mainAxisSpacing: 1),
                              ),
                            ),
                          ],
                        );
                      }
                  }
                },
              ),
            ),
            //SizedBox(height: 15,),
            Container(
              width: 414 * horizontalScale,
              height: 250 * verticalScale,
              decoration: BoxDecoration(
                image: DecorationImage(
                  alignment: Alignment.center,
                  image: AssetImage('assets/a1.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                top: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Me',
                    textScaleFactor: min(horizontalScale, verticalScale),
                    style: TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 1),
                        fontFamily: 'Poppins',
                        fontSize: 25,
                        letterSpacing:
                            0 /*percentages not used in flutter. defaulting to zero*/,
                        fontWeight: FontWeight.w500,
                        height: 1),
                  ),
                  Container(
                    width: 60 * horizontalScale,
                    child: Divider(
                        color: Color.fromRGBO(156, 91, 255, 1), thickness: 2),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, top: 10, bottom: 20),
              child: Text(
                'I have 3\+ years experience in Machine Learning\. I have done 4 industrial IoT Machine Learning projects which includes data\-preprocessing\, data cleaning\, feature selection\, model building\, optimization and deployment to AWS Sagemaker\.  Now\, I even started my YouTube channel for sharing my ML and AWS knowledge Currently, I work with Tredence Inc. as a Data Scientist for the AI CoE (Center of Excellence) team. Here I work on challenging R&D projects and building various PoCs for winning new client projects for the company.When I had put papers in previous company, I practically had no offer. First 2 months were very difficult and disappointing as I couldn’t land any offer. But things suddenly started working out in the last month and I was able to bag 8 offers from various banks, analytical companies and some startups.I made this website to use all my interview experiences to help people land their dream job\.',
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                bottom: 10,
              ),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color.fromARGB(255, 6, 240, 185),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 8.0,
                        spreadRadius: .09,
                        offset: Offset(1, 5),
                      )
                    ]),
                width: 300 * horizontalScale,
                height: 40 * verticalScale,
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StoreScreen()),
                        );
                      },
                      child: Text(
                        'My Recommended Courses',
                        textScaleFactor: min(horizontalScale, verticalScale),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(
                      width: .01,
                    ),
                    Icon(
                      Icons.arrow_circle_right,
                      size: 30,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
