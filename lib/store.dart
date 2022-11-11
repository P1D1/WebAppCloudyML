import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/catalogue_screen.dart';
import 'package:cloudyml_app2/combo/combo_store.dart';
import 'package:cloudyml_app2/fun.dart';
import 'package:cloudyml_app2/globals.dart';
import 'package:cloudyml_app2/home.dart';
import 'package:cloudyml_app2/models/course_details.dart';
import 'package:cloudyml_app2/payments_history.dart';
import 'package:cloudyml_app2/privacy_policy.dart';
import 'package:cloudyml_app2/screens/assignment_tab_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';

import 'MyAccount/myaccount.dart';
import 'Providers/UserProvider.dart';
import 'aboutus.dart';
import 'my_Courses.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var textStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 14,
    fontFamily: "Semibold",
  );

  @override
  Widget build(BuildContext context) {

    List<CourseDetails> course = Provider.of<List<CourseDetails>>(context);
    final userProvider = Provider.of<UserProvider>(context);
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
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 70, right: 60, top: 20),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                    "Explore our hands on",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'SemiBold',
                                      color: HexColor("000000"),
                                      fontSize: 30,)
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 60, right: 60, bottom: 20),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                    "learning courses 🔥🔥🔥",
                                    style: TextStyle(
                                      color: HexColor("000000"),
                                      fontFamily: 'SemiBold',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26,)
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: screenWidth/5,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Our Courses comes with Lifetime access, Live",
                                style: TextStyle(
                                  color: HexColor("000000"),
                                  fontSize: 12,)
                            ),
                            Text(
                                "chat support & internship opportunity.",
                                style: TextStyle(
                                  color: HexColor("000000"),
                                  fontSize: 12,)
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 60.0, right: 60),
                    child: Divider(thickness: 2,),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 60.0, left: 60.0),
                    child: Container(
                      height: screenHeight,
                      child: GridView.builder(
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                          ),
                          scrollDirection: Axis.vertical,
                          itemCount: course.length,
                          itemBuilder: (BuildContext context, index) {
                            if (course[index].courseName == "null") {
                              return Container(
                                child: Text('This is a container'),
                              );
                            }
                            return GestureDetector(
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
                                  decoration: BoxDecoration(
                                    color: Colors.white,
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
                                        width: screenWidth / 3.5,
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
                                        height: 15,
                                        color: HexColor('EEE1FF'),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 8,),
                                            Image.asset(
                                              'assets/Rating.png',
                                              fit: BoxFit.fill,
                                              height: 10,
                                              width: 50,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: screenHeight / 6.5,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
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
                                      ),
                                      Container(
                                        width: screenWidth / 4.5,
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
                                              "Enroll Now!",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                  Colors.white,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold),
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container(
              color: Colors.deepPurple,
              child: Stack(children: [
                Positioned(
                  // left: -50,
                  // width: 100,
                  // height: 100,
                  top: -98.00000762939453,
                  left: -88.00000762939453,
                  // child: CircleAvatar(
                  //   radius: 70,
                  //   backgroundColor: Color.fromARGB(255, 173, 149, 149),
                  // ),
                  child: Container(
                      width: 161.99998474121094,
                      height: 161.99998474121094,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(55, 126, 106, 228),
                        borderRadius: BorderRadius.all(Radius.elliptical(
                            161.99998474121094, 161.99998474121094)),
                      )),
                ),
                Positioned(
                  // right: MediaQuery.of(context).size.width * (-.16),
                  // bottom: MediaQuery.of(context).size.height * .7,
                  top: 73.00000762939453,
                  left: 309,

                  // child: CircleAvatar(
                  //   radius: 80,
                  //   backgroundColor: Color.fromARGB(255, 173, 149, 149),
                  // ),
                  child: Container(
                      width: 161.99998474121094,
                      height: 161.99998474121094,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(55, 126, 106, 228),
                        borderRadius: BorderRadius.all(Radius.elliptical(
                            161.99998474121094, 161.99998474121094)),
                      )),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  //color: Color.fromARGB(214, 83, 109, 254),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.08,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomePage()),
                                );
                                // Scaffold.of(context).openDrawer();
                              },
                              icon: Icon(
                                Icons.arrow_back,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.17,
                            ),
                            Text(
                              'Store',
                              style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.06,
                      ),
                      Expanded(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(40),
                                  topRight: Radius.circular(40)),
                              color: Colors.white),
                          child: MediaQuery.removePadding(
                            context: context,
                            removeTop: true,
                            child: GridView.builder(
                                gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent:
                                    MediaQuery.of(context).size.width * .5,
                                    childAspectRatio: 1.15
                                ),
                                itemCount: course.length,
                                itemBuilder: (context, index) {
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
                                    child: Container(
                                      margin: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        color: Color.fromARGB(192, 255, 255, 255),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color.fromRGBO(
                                                168, 133, 250, 0.7099999785423279),
                                            offset: Offset(2, 2),
                                            blurRadius: 5,
                                          )
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(08.0),
                                        child: Column(
                                          //mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(top: 5),
                                              child: Container(
                                                child: ClipRRect(
                                                  borderRadius:
                                                  BorderRadius.circular(15),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                    course[index].courseImageUrl,
                                                    placeholder: (context, url) =>
                                                        CircularProgressIndicator(),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                        Icon(Icons.error),
                                                    fit: BoxFit.cover,
                                                    height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                        .15,
                                                    width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                        .4,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                height:
                                                MediaQuery.of(context).size.height *
                                                    .06,
                                                child: Text(
                                                  course[index].courseName,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                          .035),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height:
                                              MediaQuery.of(context).size.height *
                                                  .02,
                                            ),
                                            SingleChildScrollView(
                                              scrollDirection: Axis.vertical,
                                              child: Row(
                                                // mainAxisAlignment:
                                                //     MainAxisAlignment
                                                //         .center,
                                                children: [
                                                  Text(
                                                    course[index].courseLanguage,
                                                    style: TextStyle(
                                                        fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                            .03),
                                                  ),
                                                  SizedBox(
                                                    width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                        .02,
                                                  ),
                                                  Text(
                                                    '||',
                                                    style: TextStyle(
                                                        fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                            .03),
                                                  ),
                                                  SizedBox(
                                                    width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                        .02,
                                                  ),
                                                  Text(
                                                    course[index].numOfVideos,
                                                    style: TextStyle(
                                                        fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                            .03),
                                                  ),
                                                  // const SizedBox(
                                                  //   height: 10,
                                                  // ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height:
                                              MediaQuery.of(context).size.height *
                                                  .015,
                                            ),
                                            // Row(
                                            //   children: [
                                            //     Container(
                                            //       width:
                                            //           MediaQuery.of(context)
                                            //                   .size
                                            //                   .width *
                                            //               0.20,
                                            //       height:
                                            //           MediaQuery.of(context)
                                            //                   .size
                                            //                   .height *
                                            //               0.030,
                                            //       decoration: BoxDecoration(
                                            //           borderRadius:
                                            //               BorderRadius
                                            //                   .circular(10),
                                            //           color: Colors.green),
                                            //       child: const Center(
                                            //         child: Text(
                                            //           'ENROLL NOW',
                                            //           style: TextStyle(
                                            //               fontSize: 10,
                                            //               color:
                                            //                   Colors.white),
                                            //         ),
                                            //       ),
                                            //     ),
                                            //     const SizedBox(
                                            //       width: 15,
                                            //     ),
                                            //     Text(
                                            //       map['Course Price'],
                                            //       style: const TextStyle(
                                            //         fontSize: 13,
                                            //         color: Colors.indigo,
                                            //         fontWeight:
                                            //             FontWeight.bold,
                                            //       ),
                                            //     ),
                                            //   ],
                                            // ),
                                            Text(
                                              course[index].coursePrice,
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                    .03,
                                                color: Colors.indigo,
                                                fontWeight: FontWeight.bold,
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
              ]),
            );
          }

        }
      ),
    );
  }
}
