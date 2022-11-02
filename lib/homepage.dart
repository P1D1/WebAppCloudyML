// ignore: import_of_legacy_library_into_null_safe
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/Providers/UserProvider.dart';
import 'package:cloudyml_app2/api/firebase_api.dart';
import 'package:cloudyml_app2/authentication/firebase_auth.dart';
import 'package:cloudyml_app2/catalogue_screen.dart';
import 'package:cloudyml_app2/combo/combo_store.dart';
import 'package:cloudyml_app2/home.dart';
import 'package:cloudyml_app2/models/course_details.dart';
import 'package:cloudyml_app2/pages/notificationpage.dart';
import 'package:cloudyml_app2/payments_history.dart';
import 'package:cloudyml_app2/privacy_policy.dart';
import 'package:cloudyml_app2/screens/assignment_tab_screen.dart';
import 'package:cloudyml_app2/store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloudyml_app2/fun.dart';
import 'package:cloudyml_app2/models/firebase_file.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:cloudyml_app2/globals.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:badges/badges.dart';
import 'package:video_player/video_player.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'MyAccount/myaccount.dart';
import 'aboutus.dart';
import 'combo/combo_course.dart';
import 'module/pdf_course.dart';
import 'module/video_screen.dart';
import 'my_Courses.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<FirebaseFile>> futureFiles;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> courses = [];
  bool? load = true;
  Map userMap = Map<String, dynamic>();

  void fetchCourses() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        courses = value.data()!['paidCourseNames'];
        load = false;
      });
    });
  }

  String? name = '';

  void getCourseName() async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .get()
        .then((value) {
      setState(() {
        name = value.data()!['name'];
        print('ufbufb--$name');
        print('ufbufb--$courseId');
      });
    });
  }

  List<Icon> list = [];

  bool navigateToCatalogueScreen(String id) {
    if (userMap['payInPartsDetails'][id] != null) {
      final daysLeft = (DateTime.parse(
              userMap['payInPartsDetails'][id]['endDateOfLimitedAccess'])
          .difference(DateTime.now())
          .inDays);
      print(daysLeft);
      return daysLeft < 1;
    } else {
      return false;
    }
  }

  bool statusOfPayInParts(String id) {
    if (!(userMap['payInPartsDetails'][id] == null)) {
      if (userMap['payInPartsDetails'][id]['outStandingAmtPaid']) {
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  void dbCheckerForPayInParts() async {
    DocumentSnapshot userDocs = await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    // print(map['payInPartsDetails'][id]['outStandingAmtPaid']);
    setState(() {
      userMap = userDocs.data() as Map<String, dynamic>;
      // whetherSubScribedToPayInParts =
      //     !(!(map['payInPartsDetails']['outStandingAmtPaid'] == null));
    });
  }

  late ScrollController _controller;
  final notificationBox = Hive.box('NotificationBox');
  bool menuClicked = false;

  // showNotification() async {
  //   final provider = Provider.of<UserProvider>(context, listen: false);
  //   if (notificationBox.isEmpty) {
  //     notificationBox.put(1, {"count": 0});
  //     provider
  //         .showNotificationHomeScreen(notificationBox.values.first["count"]);
  //   } else {
  //     provider
  //         .showNotificationHomeScreen(notificationBox.values.first["count"]);
  //   }
  // }


  @override
  void initState() {
    // showNotification();
    fetchCourses();
    _controller = ScrollController();
    super.initState();
    futureFiles = FirebaseApi.listAll('reviews/');
    getCourseName();
    dbCheckerForPayInParts();

  }

  var textStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 14,
    fontFamily: "Semibold",
  );

  var ref;

  userData() async {
    ref = await FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    print(ref.data()!["role"]);
  }

  @override
  Widget build(BuildContext context) {
    final providerNotification =
        Provider.of<UserProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context);
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    List<CourseDetails> course = Provider.of<List<CourseDetails>>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    var verticalScale = screenHeight / mockUpHeight;
    var horizontalScale = screenWidth / mockUpWidth;

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: Container(
          child: Stack(
            children: [
              ListView(
                padding: EdgeInsets.only(top: 0),
                children: [
                  Stack(
                    children: [
                      Container(
                        child: Image.network(
                            "https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2FRectangle%20133.png?alt=media&token=1c822b64-1f79-4654-9ebd-2bd0682c8e0f"),
                      ),
                      UserAccountsDrawerHeader(
                        accountName: Text(
                          userProvider.userModel?.name.toString() ??
                              'Enter name',
                        ),
                        accountEmail: Text(
                          userProvider.userModel?.email.toString() == ''
                              ? userProvider.userModel?.mobile.toString() ?? ''
                              : userProvider.userModel?.email.toString() ??
                                  'Enter email',
                        ),
                        currentAccountPicture: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyAccountPage()));
                          },
                          child: CircleAvatar(
                            foregroundColor: Colors.black,
                            //foregroundImage: NetworkImage('https://stratosphere.co.in/img/user.jpg'),
                            foregroundImage: NetworkImage(
                                userProvider.userModel?.image ?? ''),
                            backgroundColor: Colors.transparent,
                            backgroundImage: CachedNetworkImageProvider(
                              'https://stratosphere.co.in/img/user.jpg',
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(color: Colors.transparent),
                      ),
                    ],
                  ),
                  // Container(
                  //     height: height * 0.27,
                  //     //decoration: BoxDecoration(gradient: gradient),
                  //     color: HexColor('7B62DF'),
                  //     child: StreamBuilder<QuerySnapshot>(
                  //       stream: FirebaseFirestore.instance
                  //           .collection("Users")
                  //           .snapshots(),
                  //       builder: (BuildContext context,
                  //           AsyncSnapshot<QuerySnapshot> snapshot) {
                  //         if (!snapshot.hasData) return const SizedBox.shrink();
                  //         return ListView.builder(
                  //           itemCount: snapshot.data!.docs.length,
                  //           itemBuilder: (BuildContext context, index) {
                  //             DocumentSnapshot document = snapshot.data!.docs[index];
                  //             Map<String, dynamic> map = snapshot.data!.docs[index]
                  //                 .data() as Map<String, dynamic>;
                  //             if (map["id"].toString() ==
                  //                 FirebaseAuth.instance.currentUser!.uid) {
                  //               return Padding(
                  //                 padding: EdgeInsets.all(width * 0.05),
                  //                 child: Container(
                  //                   child: Column(
                  //                     crossAxisAlignment: CrossAxisAlignment.start,
                  //                     mainAxisSize: MainAxisSize.min,
                  //                     children: [
                  //                       CircleAvatar(
                  //                         radius: width * 0.089,
                  //                         backgroundImage:
                  //                             AssetImage('assets/user.jpg'),
                  //                       ),
                  //                       SizedBox(
                  //                         height: height * 0.01,
                  //                       ),
                  //                       map['name'] != null
                  //                           ? Text(
                  //                               map['name'],
                  //                               style: TextStyle(
                  //                                   color: Colors.white,
                  //                                   fontWeight: FontWeight.w500,
                  //                                   fontSize: width * 0.049),
                  //                             )
                  //                           : Text(
                  //                               map['mobilenumber'],
                  //                               style: TextStyle(
                  //                                   color: Colors.white,
                  //                                   fontWeight: FontWeight.w500,
                  //                                   fontSize: width * 0.049),
                  //                             ),
                  //                       SizedBox(
                  //                         height: height * 0.007,
                  //                       ),
                  //                       map['email'] != null
                  //                           ? Text(
                  //                               map['email'],
                  //                               style: TextStyle(
                  //                                   color: Colors.white,
                  //                                   fontSize: width * 0.038),
                  //                             )
                  //                           : Container(),
                  //                     ],
                  //                   ),
                  //                 ),
                  //               );
                  //             } else {
                  //               return Container();
                  //             }
                  //           },
                  //         );
                  //       },
                  //     )
                  // ),
                  InkWell(
                    child: ListTile(
                      title: Text('Home'),
                      leading: Icon(
                        Icons.home,
                        color: HexColor('691EC8'),
                      ),
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      );
                    },
                  ),
                  InkWell(
                    child: ListTile(
                      title: Text(''
                          'My Account'),
                      leading: Icon(
                        Icons.person,
                        color: HexColor('691EC8'),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyAccountPage()));
                    },
                  ),
                  InkWell(
                    child: ListTile(
                      title: Text('My Courses'),
                      leading: Icon(
                        Icons.assignment,
                        color: HexColor('691EC8'),
                      ),
                    ),
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                    },
                  ),
                  //Assignments tab for mentors only
                  ref != null
                      ? ref.data()['role'] != 'mentor'
                          ? InkWell(
                              child: ListTile(
                                title: Text('Assignments'),
                                leading: Icon(
                                  Icons.assignment_ind_outlined,
                                  color: HexColor('691EC8'),
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Assignments()));
                              },
                            )
                          : SizedBox()
                      : SizedBox(),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PaymentHistory()));
                    },
                    child: ListTile(
                      title: Text('Payment History'),
                      leading: Icon(
                        Icons.payment_rounded,
                        color: HexColor('691EC8'),
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PrivacyPolicy()));
                    },
                    child: ListTile(
                      title: Text('Privacy policy'),
                      leading: Icon(
                        Icons.privacy_tip,
                        color: HexColor('691EC8'),
                      ),
                    ),
                  ),
                  InkWell(
                    child: ListTile(
                      title: Text('About Us'),
                      leading: Icon(
                        Icons.info,
                        color: HexColor('691EC8'),
                      ),
                    ),
                    onTap: () async {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AboutUs()));
                    },
                  ),
                  // InkWell(
                  //   child: ListTile(
                  //     title: Text('Notification Local'),
                  //     leading: Icon(
                  //       Icons.book,
                  //       color: HexColor('6153D3'),
                  //     ),
                  //   ),
                  //   ),
                  //   onTap: () async {
                  //
                  //     await AwesomeNotifications().createNotification(
                  //         content:NotificationContent(
                  //             id:  1234,
                  //             channelKey: 'image',
                  //           title: 'Welcome to CloudyML',
                  //           body: 'It\'s great to have you on CloudyML',
                  //           bigPicture: 'asset://assets/HomeImage.png',
                  //           largeIcon: 'asset://assets/logo2.png',
                  //           notificationLayout: NotificationLayout.BigPicture,
                  //           displayOnForeground: true
                  //         )
                  //     );
                  //     // LocalNotificationService.showNotificationfromApp(
                  //     //   title: 'Welcome to CloudyML',
                  //     //   body: 'It\'s great to have you on CloudyML',
                  //     //   payload: 'account'
                  //     // );
                  //   },
                  // ),
                ],
              ),
              Positioned(
                top: 10,
                right: 10,
                child: CircleAvatar(
                    maxRadius: 16,
                    backgroundColor: Colors.white,
                    child: Center(
                      child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 12,
                          )),
                    )),
              ),
            ],
          ),
        ),
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth >= 515) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeight,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/homepage/newBGImage.png'),
                        fit: BoxFit.fill),
                  ),
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                Scaffold.of(context).openDrawer();
                                menuClicked = true;
                              },
                              icon: Icon(
                                Icons.menu,
                                color: Colors.white,
                              )),
                          SizedBox(
                            width: horizontalScale * 15,
                          ),
                          Image.asset(
                            "assets/logo2.png",
                            width: 30,
                            height: 30,
                          ),
                          Text(
                            "CloudyML",
                            style: textStyle,
                          ),
                          SizedBox(
                            width: horizontalScale * 275,
                          ),
                          constraints.maxWidth < 800
                              ? Expanded(
                                  child: ElevatedButton(
                                      onPressed: () {
                                        logOut(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: HexColor("8346E1"),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                      ),
                                      child: Text("Log out", style: textStyle)),
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    logOut(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: HexColor("8346E1"),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                  child: Text("Log out", style: textStyle)),
                        ],
                      ),
                      Positioned(
                        top: 50,
                        right: 75,
                        child: Container(
                            height: screenHeight / 1.5,
                            width: screenWidth / 2.5,
                            child: Image.asset(
                              'assets/homepage/Webgraphics21.png',
                              fit: BoxFit.fill,
                            )),
                      ),
                      Positioned(
                        top: 125,
                        left: 75,
                        child: Container(
                            height: screenHeight / 3,
                            width: screenWidth / 2.5,
                            child: Image.network(
                              'https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2FGroup%20162.png?alt=media&token=6e3f0646-61b4-4897-ae9d-9ef3600676e1',
                              fit: BoxFit.fill,
                            )),
                      ),
                      // Positioned(
                      //   top: 400,
                      //   left: 78,
                      //   child: Container(
                      //     child: ElevatedButton(
                      //       onPressed: () {
                      //         Scaffold.of(context).openDrawer();
                      //       },
                      //       style: ElevatedButton.styleFrom(
                      //         backgroundColor: HexColor("8346E1"),
                      //       ),
                      //       child: Row(
                      //         children: [
                      //           Text(
                      //             "View Courses",
                      //             style: textStyle,
                      //           ),
                      //           SizedBox(
                      //             width: 10,
                      //           ),
                      //           CircleAvatar(
                      //               maxRadius: 10,
                      //               backgroundColor: Colors.white,
                      //               child: Icon(
                      //                 Icons.arrow_forward_outlined,
                      //                 color: Colors.black,
                      //                 size: 14,
                      //               )),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      Center(
                          child: Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Text(
                          "My Enrolled Courses",
                          style: TextStyle(
                              fontFamily: 'Medium',
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                      courses.length > 0
                          ? Container(
                              width: screenWidth / 2.5,
                              height: screenHeight / 5.5,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black26,
                                      offset: Offset(
                                        2, // Move to right 10  horizontally
                                        2.0, // Move to bottom 10 Vertically
                                      ),
                                      blurRadius: 40)
                                ],
                                border: Border.all(
                                  color: HexColor('440F87'),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                // shrinkWrap: true,
                                itemCount: course.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (course[index].courseName == "null") {
                                    return Container();
                                  }
                                  if (courses
                                      .contains(course[index].courseId)) {
                                    return InkWell(
                                      onTap: (() {
                                        // setModuleId(snapshot.data!.docs[index].id);
                                        getCourseName();
                                        if (navigateToCatalogueScreen(
                                            course[index].courseId) &&
                                            !(userMap['payInPartsDetails']
                                            [course[index].courseId]
                                            ['outStandingAmtPaid'])) {
                                          if (!course[index].isItComboCourse) {
                                            Navigator.push(
                                              context,
                                              PageTransition(
                                                duration: Duration(milliseconds: 400),
                                                curve: Curves.bounceInOut,
                                                type:
                                                PageTransitionType.rightToLeftWithFade,
                                                child: VideoScreen(
                                                  isDemo: true,
                                                  courseName: course[index].courseName,
                                                  sr: 1,
                                                ),
                                              ),
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              PageTransition(
                                                duration: Duration(milliseconds: 100),
                                                curve: Curves.bounceInOut,
                                                type:
                                                PageTransitionType.rightToLeftWithFade,
                                                child: ComboStore(
                                                  courses: course[index].courses,
                                                ),
                                              ),
                                            );
                                          }
                                        } else {
                                          if (!course[index].isItComboCourse) {
                                            if (course[index].courseContent == 'pdf') {
                                              Navigator.push(
                                                context,
                                                PageTransition(
                                                  duration: Duration(milliseconds: 400),
                                                  curve: Curves.bounceInOut,
                                                  type: PageTransitionType
                                                      .rightToLeftWithFade,
                                                  child: PdfCourseScreen(
                                                    curriculum: course[index].curriculum
                                                    as Map<String, dynamic>,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              Navigator.push(
                                                context,
                                                PageTransition(
                                                  duration: Duration(milliseconds: 400),
                                                  curve: Curves.bounceInOut,
                                                  type: PageTransitionType
                                                      .rightToLeftWithFade,
                                                  child: VideoScreen(
                                                    isDemo: true,
                                                    courseName: course[index].courseName,
                                                    sr: 1,
                                                  ),
                                                ),
                                              );
                                            }
                                          } else {
                                            ComboCourse.comboId.value =
                                                course[index].courseId;
                                            Navigator.push(
                                              context,
                                              PageTransition(
                                                duration: Duration(milliseconds: 400),
                                                curve: Curves.bounceInOut,
                                                type:
                                                PageTransitionType.rightToLeftWithFade,
                                                child: ComboCourse(
                                                  courses: course[index].courses,
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                        setState(() {
                                          courseId = course[index].courseDocumentId;
                                        });
                                      }),
                                      child: Container(
                                        width: screenWidth / 2.5,
                                        height: screenHeight / 5.5,
                                        child: Stack(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 60 * horizontalScale,
                                                    height: screenHeight / 5.5,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors
                                                                .transparent),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        image: DecorationImage(
                                                            image:
                                                                CachedNetworkImageProvider(
                                                              course[index]
                                                                  .courseImageUrl,
                                                            ),
                                                            fit: BoxFit.fill)),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Expanded(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.topCenter,
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            course[index]
                                                                .courseName,
                                                            style: TextStyle(
                                                                color: HexColor(
                                                                    "2C2C2C"),
                                                                fontFamily:
                                                                    'Medium',
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                height: 1),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              SizedBox(
                                                                height: 5,
                                                                width: 150,
                                                                child:
                                                                    LinearProgressIndicator(
                                                                  value: 0.65,
                                                                  color: HexColor(
                                                                      "8346E1"),
                                                                  backgroundColor:
                                                                      HexColor(
                                                                          'E3E3E3'),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                    "${((course.length / int.parse(course[index].numOfVideos)) * 100).roundToDouble()}%"),
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                            )
                          : Container(
                              child: Text('There are zero courses'),
                            ),
                      SizedBox(height: 40),
                      // Padding(
                      //   padding: const EdgeInsets.all(15.0),
                      //   child: Container(
                      //     child: ElevatedButton(
                      //         onPressed: () {}, child: Text("View More")),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                Container(
                  height: screenHeight / 1.9,
                  width: screenWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      stops: [0, 0.4, 0.9],
                      colors: [
                        HexColor("FFFFFF"),
                        HexColor("B079FF"),
                        HexColor("FFFFFF"),
                      ],
                    ),
                  ),
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Reviews',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Poppins',
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      FutureBuilder<List<FirebaseFile>>(
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
                                  textScaleFactor:
                                      min(horizontalScale, verticalScale),
                                ));
                              } else {
                                final files = snapshot.data!;
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: screenHeight / 2.3,
                                    child: CarouselSlider.builder(
                                      itemCount: files.length,
                                      itemBuilder: (BuildContext context,
                                              int index, int pageNo) =>
                                          ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.network(
                                                  files[index].url)),
                                      options: CarouselOptions(
                                        autoPlay: true,
                                        enableInfiniteScroll: true,
                                        enlargeCenterPage: true,
                                        viewportFraction: 0.8,
                                        aspectRatio: 1.0,
                                        initialPage: 0,
                                        autoPlayCurve: Curves.fastOutSlowIn,
                                        autoPlayAnimationDuration:
                                            Duration(milliseconds: 1000),
                                      ),
                                    ),
                                  ),
                                );
                              }
                          }
                        },
                      )
                    ],
                  ),
                ),
                Container(
                  width: screenWidth,
                  color: Colors.white,
                  child: Stack(
                    children: [
                      Image.network(
                        'https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2FfeatureBG.png?alt=media&token=f350c99d-a928-48b6-9eff-983ad8797de9',
                        fit: BoxFit.fitWidth,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              "Feature Courses",
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Poppins',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Expanded(
                          child: Container(
                            margin: EdgeInsets.only(top: 150, bottom: 50),
                            height: screenHeight / 2,
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: course.length,
                                itemBuilder: (BuildContext context, index) {
                                  if (course[index].courseName == "null") {
                                    return Container();
                                  }
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        print(
                                            "Screen width is  ${screenWidth / 7}");
                                        courseId =
                                            course[index].courseDocumentId;
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
                                                const CatelogueScreen(),
                                          ),
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Container(
                                        width: screenWidth / 5,
                                        height: screenHeight / 2,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              offset: Offset(0, 2),
                                              blurRadius: 40,
                                            ),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                              width: 0.5,
                                              color: HexColor("440F87")),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: screenWidth / 5,
                                              height: screenHeight / 6,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(15),
                                                    topRight:
                                                        Radius.circular(15)),
                                                child: Image.network(
                                                  course[index].courseImageUrl,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: screenHeight / 5.5,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      children: [
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Text(
                                                            course[index]
                                                                .courseName,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    'Medium',
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                height: 1),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Text(
                                                            "- ${course[index].courseLanguage} Language",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 10),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Text(
                                                            "- ${course[index].numOfVideos} Videos",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 10),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Text(
                                                            "- Lifetime Access",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 10),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton(
                                                        onPressed: () {},
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              HexColor(
                                                                  "8346E1"),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                        ),
                                                        child: Text(
                                                          "${course[index].coursePrice}",
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Image.asset(
                                                      'assets/Rating.png',
                                                      fit: BoxFit.fill,
                                                      height: 11,
                                                      width: 50,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: screenWidth,
                  height: screenHeight / 3,
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: screenWidth / 2.4,
                        height: screenHeight / 5.5,
                        decoration: BoxDecoration(
                            color: HexColor("FFF4CB"),
                            border: Border.all(
                              color: HexColor('BE9400'),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, bottom: 10, left: 20, right: 20),
                              child: Image.network(
                                "https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2FdownloadLogo.png?alt=media&token=031e6f59-cbc4-4c6a-a735-db14da7ec1fd",
                                fit: BoxFit.fill,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10.0, right: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Download The App Now!',
                                    style: TextStyle(
                                        color: HexColor("C19700"),
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  SizedBox(height: 8,),
                                  Text(
                                    'Learn new skill anywhere any time',
                                    style: TextStyle(
                                        color: HexColor("231F20"),
                                        fontFamily: 'Poppins',
                                        fontSize: 12),
                                  ),
                                  SizedBox(height: 10,),
                                  Row(
                                    children: [
                                      Container(
                                        child: Image.network(
                                          "https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2FplaystoreIcon.png?alt=media&token=526c9fc9-0ec4-4b89-b991-cb42e272a1bd",
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      SizedBox(width: 5,),
                                      Container(
                                        child: Image.network(
                                          "https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2FappStoreLogo.png?alt=media&token=bc836ab8-451e-402b-9c48-cb16d02e9861",
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Container(
                        width: screenWidth / 2.4,
                        height: screenHeight / 5.5,
                        decoration: BoxDecoration(
                            color: HexColor("CBE9FF"),
                            border: Border.all(
                              color: HexColor('007EDA'),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, bottom: 10, left: 20, right: 20),
                              child: Image.network(
                                "https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2Freward.png?alt=media&token=4266fe1f-8875-4c52-8e83-42e65a08fb4c",
                                fit: BoxFit.fill,
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.only(top: 10.0, right: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Learn, Sell & Earn',
                                    style: TextStyle(
                                        color: HexColor("007EDA"),
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  SizedBox(height: 8,),
                                  Text(
                                    'Join our affiliate program and grow with us',
                                    style: TextStyle(
                                        color: HexColor("231F20"),
                                        fontFamily: 'Poppins',
                                        fontSize: 10),
                                  ),
                                  SizedBox(height: 10,),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: HexColor('CBE9FF'),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(25),
                                          )
                                        ),
                                        child: Text("Explore More",
                                          style:  TextStyle(
                                            fontSize: 12,
                                      color: HexColor("2C2C2C"),
                                    ),)),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return SingleChildScrollView(
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
                                    size: 30 *
                                        min(horizontalScale, verticalScale),
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
                                    print(
                                        "-------------${notificationBox.values}");
                                    if (snapshot.data!.docs.length <
                                        data.countNotification) {
                                      notificationBox.put(1, {
                                        "count": (snapshot.data!.docs.length)
                                      });
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
                                            "count":
                                                (snapshot.data!.docs.length)
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
                                                    notificationBox.values
                                                        .first["count"] >=
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
                                        end: data.countNotification >= 100
                                            ? 2
                                            : 7,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 10 * verticalScale,
                                        ),
                                        Container(
                                          width: 194,
                                          child: Text(
                                            course[index].courseName,
                                            textScaleFactor: min(
                                                horizontalScale, verticalScale),
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
                                                  horizontalScale,
                                                  verticalScale),
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      88, 88, 88, 1),
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
                                                  horizontalScale,
                                                  verticalScale),
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
                              textScaleFactor:
                                  min(horizontalScale, verticalScale),
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
                            color: Color.fromRGBO(156, 91, 255, 1),
                            thickness: 2),
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
                            textScaleFactor:
                                min(horizontalScale, verticalScale),
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
          );
        }
      }),
    );
  }
}
