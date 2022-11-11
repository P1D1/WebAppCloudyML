import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/combo/combo_course.dart';
import 'package:cloudyml_app2/combo/combo_store.dart';
import 'package:cloudyml_app2/globals.dart';
import 'package:cloudyml_app2/models/course_details.dart';
import 'package:cloudyml_app2/module/video_screen.dart';
import 'package:cloudyml_app2/payments_history.dart';
import 'package:cloudyml_app2/privacy_policy.dart';
import 'package:cloudyml_app2/screens/assignment_tab_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'MyAccount/myaccount.dart';
import 'Providers/UserProvider.dart';
import 'aboutus.dart';
import 'authentication/firebase_auth.dart';
import 'catalogue_screen.dart';
import 'home.dart';
import 'module/pdf_course.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchString = "";
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  // bool? whetherSubScribedToPayInParts = false;
  String id = "";

  // String daysLeftOfLimitedAccess = "";
  List<dynamic> courses = [];

  Map userMap = Map<String, dynamic>();

  bool? load = true;

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

  var ref;

  userData() async {
    ref = await FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    print(ref.data()!["role"]);
  }

  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    super.initState();
    fetchCourses();
    dbCheckerForPayInParts();
    getCourseName();
    userData();
    // dbCheckerForDaysLeftForLimitedAccess();
  }

  var textStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 14,
    fontFamily: "Semibold",
  );

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
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
                                ? userProvider.userModel?.mobile.toString() ??
                                    ''
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
                    height: 45,
                    color: HexColor("440F87"),
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
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
                          width: horizontalScale * 25,
                        ),
                        SizedBox(
                          height: 30,
                          width: screenWidth / 3,
                          child: TextField(
                            style: TextStyle(
                                color: HexColor("A7A7A7"), fontSize: 12),
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(5.0),
                                hintText: "Search Courses",
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 1)),
                                disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 1)),
                                hintStyle: TextStyle(
                                    color: HexColor("A7A7A7"), fontSize: 12),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 1)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 1)),
                                prefixIcon: IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.search_outlined,
                                      size: 14,
                                      color: Colors.white,
                                    ))),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 60, right: 60, top: 40),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Welcome back ${ref.data()!["name"]}, Continue learning",
                        style: TextStyle(
                            color: HexColor("231F20"),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SemiBold'),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 60, right: 60, top: 10),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Enrolled Courses",
                        style: TextStyle(
                            color: HexColor("231F20"),
                            fontSize: 22,)
                      ),
                    ),
                  ),
                  courses.length > 0
                      ? Padding(
                        padding: const EdgeInsets.only(top: 30.0, left: 60, right: 60),
                        child: Container(
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
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 5.0, bottom: 5),
                                                    child: Align(
                                                      alignment:
                                                      Alignment.topLeft,
                                                      child: Image.asset(
                                                        'assets/Rating.png',
                                                        fit: BoxFit.fill,
                                                        height: 10,
                                                        width: 100,
                                                      ),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment: Alignment.topLeft,
                                                    child: Text(
                                                      "${course[index]
                                                          .courseLanguage} || ${course[index]
                                                          .numOfVideos} Videos",
                                                      style: TextStyle(
                                                          color: HexColor(
                                                              "2C2C2C"),
                                                          fontFamily:
                                                          'Medium',
                                                          fontSize: 12,
                                                          fontWeight:
                                                          FontWeight
                                                              .w500,
                                                          height: 1),
                                                    ),
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
                  ),
                      )
                      : Container(
                    child: Text('There are zero courses'),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 60, right: 60, top: 10),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                          "Popular Courses",
                          style: TextStyle(
                            color: HexColor("231F20"),
                            fontSize: 22,)
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 60.0, left: 60.0),
                    child: Container(
                      margin: EdgeInsets.only(top: 15, bottom: 15),
                      height: screenHeight / 2,
                      child: Center(
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
            );
          } else {
            return Stack(
              children: [
                Positioned(
                  top: -147 * verticalScale,
                  left: 2.4e-7 * horizontalScale,
                  child: Container(
                    width: 414 * horizontalScale,
                    height: 414 * verticalScale,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      color: Color.fromRGBO(122, 98, 222, 1),
                    ),
                  ),
                ),
                Positioned(
                  top: 137 * verticalScale,
                  left: 348 * horizontalScale,
                  child: Container(
                    width: 162 * min(horizontalScale, verticalScale),
                    height: 162 * min(horizontalScale, verticalScale),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(126, 106, 228, 1),
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(162, 162)),
                    ),
                  ),
                ),
                Positioned(
                  top: -105 * verticalScale,
                  left: -91 * horizontalScale,
                  child: Container(
                    width: 162 * min(horizontalScale, verticalScale),
                    height: 162 * min(horizontalScale, verticalScale),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(126, 106, 228, 1),
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(162, 162)),
                    ),
                  ),
                ),
                Positioned(
                  top: 102 * verticalScale,
                  left: 102 * horizontalScale,
                  child: Text(
                    'My Courses',
                    textAlign: TextAlign.center,
                    textScaleFactor: min(horizontalScale, verticalScale),
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontFamily: 'Poppins',
                      fontSize: 35,
                      letterSpacing:
                          0 /*percentages not used in flutter. defaulting to zero*/,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ),
                courses.length > 0
                    ? Positioned(
                        top: 0 * verticalScale,
                        left: 0 * horizontalScale,
                        child: Container(
                          width: screenWidth,
                          height: screenHeight,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            // shrinkWrap: true,
                            itemCount: course.length,
                            itemBuilder: (BuildContext context, int index) {
                              if (course[index].courseName == "null") {
                                return Container();
                              }
                              if (courses.contains(course[index].courseId)) {
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
                                            duration:
                                                Duration(milliseconds: 400),
                                            curve: Curves.bounceInOut,
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                            child: VideoScreen(
                                              isDemo: true,
                                              courseName:
                                                  course[index].courseName,
                                              sr: 1,
                                            ),
                                          ),
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            duration:
                                                Duration(milliseconds: 100),
                                            curve: Curves.bounceInOut,
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                            child: ComboStore(
                                              courses: course[index].courses,
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      if (!course[index].isItComboCourse) {
                                        if (course[index].courseContent ==
                                            'pdf') {
                                          Navigator.push(
                                            context,
                                            PageTransition(
                                              duration:
                                                  Duration(milliseconds: 400),
                                              curve: Curves.bounceInOut,
                                              type: PageTransitionType
                                                  .rightToLeftWithFade,
                                              child: PdfCourseScreen(
                                                curriculum:
                                                    course[index].curriculum
                                                        as Map<String, dynamic>,
                                              ),
                                            ),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            PageTransition(
                                              duration:
                                                  Duration(milliseconds: 400),
                                              curve: Curves.bounceInOut,
                                              type: PageTransitionType
                                                  .rightToLeftWithFade,
                                              child: VideoScreen(
                                                isDemo: true,
                                                courseName:
                                                    course[index].courseName,
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
                                            duration:
                                                Duration(milliseconds: 400),
                                            curve: Curves.bounceInOut,
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
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
                                  child: Stack(
                                    children: [
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: 230 * verticalScale,
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Container(
                                                width: 177 * horizontalScale,
                                                height: 92 * verticalScale,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(25),
                                                    topRight:
                                                        Radius.circular(25),
                                                    bottomLeft:
                                                        Radius.circular(0),
                                                    bottomRight:
                                                        Radius.circular(0),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Color.fromRGBO(
                                                            29, 28, 31, 0.3),
                                                        offset: Offset(2, 2),
                                                        blurRadius: 47)
                                                  ],
                                                  image: DecorationImage(
                                                      image:
                                                          CachedNetworkImageProvider(
                                                        course[index]
                                                            .courseImageUrl,
                                                      ),
                                                      fit: BoxFit.fitWidth),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Stack(
                                                children: [
                                                  Container(
                                                    width:
                                                        177 * horizontalScale,
                                                    height:
                                                        200 * verticalScale / 2,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        bottomLeft:
                                                            Radius.circular(25),
                                                        bottomRight:
                                                            Radius.circular(25),
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color:
                                                                Color.fromRGBO(
                                                              29,
                                                              28,
                                                              31,
                                                              0.3,
                                                            ),
                                                            offset:
                                                                Offset(2, 2),
                                                            blurRadius: 47)
                                                      ],
                                                      color: Color.fromRGBO(
                                                        255,
                                                        255,
                                                        255,
                                                        1,
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 5 * verticalScale,
                                                    left: 10 * horizontalScale,
                                                    right: 10 * horizontalScale,
                                                    child: Container(
                                                      child: Text(
                                                        course[index]
                                                            .courseName,
                                                        textScaleFactor:
                                                            horizontalScale,
                                                        style: TextStyle(
                                                            color:
                                                                Color.fromRGBO(
                                                              0,
                                                              0,
                                                              0,
                                                              1,
                                                            ),
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 15,
                                                            letterSpacing:
                                                                0 /*percentages not used in flutter. defaulting to zero*/,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            height: 1),
                                                        // overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  course[index]
                                                              .isItComboCourse &&
                                                          statusOfPayInParts(
                                                              course[index]
                                                                  .courseId)
                                                      ? Positioned(
                                                          top: 35 *
                                                              verticalScale,
                                                          left: 10 *
                                                              horizontalScale,
                                                          child: Container(
                                                            child: !navigateToCatalogueScreen(
                                                                    course[index]
                                                                        .courseId)
                                                                ? Container(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.08 *
                                                                        verticalScale,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .circular(
                                                                        10,
                                                                      ),
                                                                      color:
                                                                          Color(
                                                                        0xFFC0AAF5,
                                                                      ),
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceEvenly,
                                                                      children: [
                                                                        SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Text(
                                                                          'Access ends in days : ',
                                                                          textScaleFactor: min(
                                                                              horizontalScale,
                                                                              verticalScale),
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                13,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                            color:
                                                                                Colors.grey.shade100,
                                                                          ),
                                                                          width:
                                                                              30 * min(horizontalScale, verticalScale),
                                                                          height:
                                                                              30 * min(horizontalScale, verticalScale),
                                                                          // color:
                                                                          //     Color(0xFFaefb2a),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text(
                                                                              '${(DateTime.parse(userMap['payInPartsDetails'][course[index].courseId]['endDateOfLimitedAccess']).difference(DateTime.now()).inDays)}',
                                                                              textScaleFactor: min(horizontalScale, verticalScale),
                                                                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold
                                                                                  // fontSize: 16,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                : Container(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.08,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      color: Color(
                                                                          0xFFC0AAF5),
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        'Limited access expired !',
                                                                        textScaleFactor: min(
                                                                            horizontalScale,
                                                                            verticalScale),
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.deepOrange[600],
                                                                          fontSize:
                                                                              13,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: 395 * verticalScale,
                                          ),
                                          course[index].isItComboCourse
                                              ? Row(
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          30 * horizontalScale,
                                                    ),
                                                    Stack(
                                                      children: [
                                                        Positioned(
                                                          // top: 70 * verticalScale,
                                                          // left: 10 * horizontalScale,
                                                          child: Container(
                                                            width: 60 *
                                                                horizontalScale,
                                                            height: 40 *
                                                                verticalScale,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              color: Color(
                                                                  0xFF7860DC),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                'COMBO',
                                                                textScaleFactor: min(
                                                                    horizontalScale,
                                                                    verticalScale),
                                                                style:
                                                                    const TextStyle(
                                                                  fontFamily:
                                                                      'Bold',
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ))
                    : Container(),
                Positioned(
                  top: 498 * verticalScale,
                  left: 36 * horizontalScale,
                  child: Text(
                    'Popular Courses',
                    textAlign: TextAlign.left,
                    textScaleFactor: min(horizontalScale, verticalScale),
                    style: TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 1),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        letterSpacing:
                            0 /*percentages not used in flutter. defaulting to zero*/,
                        height: 1),
                  ),
                ),
                Positioned(
                  top: 530 * verticalScale,
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.0 * verticalScale),
                    child: Container(
                      width: screenWidth,
                      height: screenHeight * 0.4,
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: course.length,
                          itemBuilder: (BuildContext context, index) {
                            if (course[index].courseName == "null") {
                              return Container();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 18.0),
                              child: InkWell(
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
                                            const CatelogueScreen(),
                                      ),
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.09),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      // height: MediaQuery.of(context).size.height * 0.16,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Color(0xFFE9E1FC),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Color.fromRGBO(
                                                  29, 28, 30, 0.3),
                                              offset: Offset(2, 2),
                                              blurStyle: BlurStyle.outer,
                                              blurRadius: 35)
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              height: 100 *
                                                  min(horizontalScale,
                                                      verticalScale),
                                              width: 100 *
                                                  min(horizontalScale,
                                                      verticalScale),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: CachedNetworkImage(
                                                    imageUrl: course[index]
                                                        .courseImageUrl,
                                                    placeholder: (context,
                                                            url) =>
                                                        CircularProgressIndicator(),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                course[index].isItComboCourse ==
                                                        true
                                                    ? Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30),
                                                            gradient: gradient),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: Text(
                                                            'COMBO',
                                                            textScaleFactor: min(
                                                                horizontalScale,
                                                                verticalScale),
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'SemiBold',
                                                                fontSize: 8,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                      )
                                                    : Container(),
                                                Container(
                                                  child: Text(
                                                    course[index].courseName,
                                                    textScaleFactor: min(
                                                        horizontalScale,
                                                        verticalScale),
                                                    style: const TextStyle(
                                                        fontFamily: 'Bold',
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    // maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        child: Text(
                                                          course[index]
                                                              .courseLanguage,
                                                          textScaleFactor: min(
                                                              horizontalScale,
                                                              verticalScale),
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Medium',
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.4),
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 6,
                                                      ),
                                                      Container(
                                                        child: Center(
                                                          child: Text(
                                                            '${course[index].numOfVideos} videos',
                                                            textScaleFactor: min(
                                                                horizontalScale,
                                                                verticalScale),
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Medium',
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.7),
                                                                fontSize: 10),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 80,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  course[index].coursePrice,
                                                  textScaleFactor: min(
                                                      horizontalScale,
                                                      verticalScale),
                                                  style: TextStyle(
                                                      fontFamily: 'Bold',
                                                      color: Color(0xFF6E5BD9),
                                                      fontSize: 17),
                                                ),
                                                // SizedBox(
                                                //   width: 40,
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 100 * verticalScale,
                  left: 63 * horizontalScale,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.arrow_back_sharp,
                        color: Colors.white,
                        size: 40 * min(horizontalScale, verticalScale)),
                  ),
                ),
              ],
            );
          }
        }));
  }
}
