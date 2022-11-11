import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/MyAccount/myaccount.dart';
import 'package:cloudyml_app2/Providers/UserProvider.dart';
import 'package:cloudyml_app2/aboutus.dart';
import 'package:cloudyml_app2/authentication/firebase_auth.dart';
import 'package:cloudyml_app2/payments_history.dart';
import 'package:cloudyml_app2/my_Courses.dart';
import 'package:cloudyml_app2/homepage.dart';
import 'package:cloudyml_app2/offline/offline_videos.dart';
import 'package:cloudyml_app2/privacy_policy.dart';
import 'package:cloudyml_app2/screens/assignment_tab_screen.dart';
import 'package:cloudyml_app2/screens/groups_list.dart';
import 'package:cloudyml_app2/store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  // final groupData;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int? _selectedIndex = 0;
  bool openPaymentHistory = false;
  Map<String, dynamic>? userdetails = {};

  List<Widget> screens = [
    Home(),
    StoreScreen(),
    // OfflinePage(),
    GroupsList()
  ];
  List<String> titles = [
    'Home',
    'Store',
    'Chat',
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    insertToken();
    print('UID--${FirebaseAuth.instance.currentUser!.uid}');
    Provider.of<UserProvider>(context, listen: false).reloadUserModel();
    userData();
  }

  void insertToken() async {
    print("insertToken");
    final token = await FirebaseMessaging.instance.getToken();

    await FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({"token": token});
    final data = await FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid);

    final response = data.get().then((DocumentSnapshot doc) {
      final data2 = doc.data() as Map<String, dynamic>;
      print(data2);
    });
    print(response);
    print("insertedToken");
  }

  void getuserdetails() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      print(value.data());
      setState(() {
        userdetails = value.data();
      });
    });
  }
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
    final userProvider = Provider.of<UserProvider>(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      body: PageView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (ctx, index) {
            if (openPaymentHistory) {
              return PaymentHistory();
            } else {
              return screens[_selectedIndex!];
            }
          }),
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
                  ref.data() != null && ref.data()!["role"] == 'mentor' ? InkWell(
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
                  ) : Container()
                  ,
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
      bottomNavigationBar: SizedBox(
        height: 70,
        child: BottomNavigationBar(
          iconSize: 24,
          backgroundColor: Colors.grey.shade50,
          elevation: 0,
          selectedItemColor: Colors.black,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
              openPaymentHistory = false;
            });
          },
          currentIndex: _selectedIndex!,
          items: [
            BottomNavigationBarItem(
              icon: new Icon(
                Icons.home_outlined,
                color: Colors.black.withOpacity(0.5),
              ),
              activeIcon: Icon(
                Icons.home,
                color: Colors.black,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.store_outlined,
                  color: Colors.black.withOpacity(0.5)),
              activeIcon: Icon(
                Icons.store,
                color: Colors.black,
              ),
              label: 'Store',
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.chat_bubble_outline_sharp,
                  color: Colors.black.withOpacity(0.5)),
              activeIcon: Icon(
                Icons.chat_bubble_outline_sharp,
                color: Colors.black,
              ),
              label: 'Chat',
            ),
          ],
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}

// StreamBuilder<QuerySnapshot>(
// stream: FirebaseFirestore.instance
//     .collection("Users")
// .snapshots(),
// builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot) {
// if (!snapshot.hasData) return const SizedBox.shrink();
// return ListView.builder(
// itemCount: snapshot.data!.docs.length,
// itemBuilder: (BuildContext context, index) {
// DocumentSnapshot document =
// snapshot.data!.docs[index];
// Map<String, dynamic> map = snapshot.data!.docs[0]
//     .data() as Map<String, dynamic>;
// if (map["id"].toString() ==
// FirebaseAuth.instance.currentUser!.uid) {
// print('Printing map ${map}');
// return UserAccountsDrawerHeader(
// // accountEmail: userdetails!=null?Text(userdetails!['email']):Text(''),
// // accountName: userdetails!=null?Text(userdetails!['name']):Text(''),
// accountEmail: map['email'] != null ? Text(map['email']) : Text(' '),
// accountName: map['name'] != null ? Text(map['name']) : Text(' '),
// currentAccountPicture: GestureDetector(
// // onTap: (){
// //   Navigator.push(context, MaterialPageRoute(builder: (context)=>AccountInfo()));
// // },
// child: CircleAvatar(
// backgroundColor: Colors.transparent,
// backgroundImage: NetworkImage(
// 'https://stratosphere.co.in/img/user.jpg'),
// ),
// ),
// decoration: BoxDecoration(
// color: HexColor('7B62DF'),
// ),
// );
// } else {
// return Container();
// }
// }
// );
// },
// ),
