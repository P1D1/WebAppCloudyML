import 'dart:async';
import 'package:cloudyml_app2/MyAccount/myaccount.dart';
import 'package:cloudyml_app2/Providers/AppProvider.dart';
import 'package:cloudyml_app2/Providers/UserProvider.dart';
import 'package:cloudyml_app2/Providers/chat_screen_provider.dart';
import 'package:cloudyml_app2/Services/database_service.dart';
import 'package:cloudyml_app2/authentication/firebase_auth.dart';
import 'package:cloudyml_app2/models/course_details.dart';
import 'package:cloudyml_app2/models/video_details.dart';
import 'package:cloudyml_app2/my_Courses.dart';
import 'package:cloudyml_app2/screens/chat_screen.dart';
import 'package:cloudyml_app2/screens/splash.dart';
import 'package:cloudyml_app2/services/local_notificationservice.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';




//Recieve message when app is in background ...solution for on message
Future<void> backgroundHandler(RemoteMessage message) async {
  // print("backgroundMessage=======================");
  // print(message.data.toString());
  // print(message.notification!.title);
  // print(message.notification!.android!.count);
  // print(message.ttl);

  // int? ttl = message.ttl;
  // print(message.messageId![0] as int);


  //  final FlutterLocalNotificationsPlugin
  // _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();



  // print(message.notification.)
  // LocalNotificationService.showNotificationfromApp(title: message.notification!.title,body: message.notification!.body);
// LocalNotificationService.createanddisplaynotification(message);

  // await Firebase.initializeApp();
  // await Hive.initFlutter();
  // await Hive.openBox('myBox');
  // final myBox = Hive.box('myBox');
  //   print("MEssage");
  //   var data = await LocalNotificationService.display(message,message.notification!.title);
  //   print("Background = $data");
  //   await myBox.put(data["ID"], data);
  //   await myBox.delete(data["ID"]);
  //   print("Message removed");

}



Future<void> main() async {

  await Hive.initFlutter();
  await Hive.openBox('myBox');
  await Hive.openBox("NotificationBox");
  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyBdAio1wI3RVwl32RoKE7F9GNG_oWBpfbM",
          appId: "1:67056708090:web:f4a43d6b987991016ddc43",
          messagingSenderId: "67056708090",
          projectId: "cloudyml-app",
          storageBucket: "cloudyml-app.appspot.com",
          databaseURL: "https://cloudyml-app-default-rtdb.firebaseio.com",
          authDomain: "cloudyml-app.firebaseapp.com")
  );

  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  LocalNotificationService.initialize();
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // showNoInternet() {
    //   AlertDialog alert = AlertDialog(
    //     content: Padding(
    //       padding: const EdgeInsets.all(18.0),
    //       child: Container(
    //         height: MediaQuery.of(context).size.height * 0.3,
    //         width: MediaQuery.of(context).size.width,
    //         child: Center(
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               SizedBox(
    //                 height: 10,
    //               ),
    //               Icon(
    //                 Icons.signal_wifi_connected_no_internet_4_rounded,
    //                 color: Colors.red,
    //                 size: 70,
    //               ),
    //               SizedBox(
    //                 height: 10,
    //               ),
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   SizedBox(),
    //                   Row(
    //                     children: [
    //                       InkWell(
    //                         onTap: () {
    //                           Navigator.of(context).pop();
    //                         },
    //                         child: Container(
    //                           decoration: BoxDecoration(
    //                             borderRadius: BorderRadius.circular(30),
    //                           ),
    //                           child: Padding(
    //                             padding: const EdgeInsets.all(4.0),
    //                             child: Text(
    //                               'Skip',
    //                               style: TextStyle(
    //                                   fontFamily: 'SemiBold',
    //                                   fontSize: 18,
    //                                   color: Colors.black),
    //                             ),
    //                           ),
    //                         ),
    //                       ),
    //                       SizedBox(
    //                         width: 6,
    //                       ),
    //                       InkWell(
    //                         onTap: () {
    //                           Navigator.push(
    //                             context,
    //                             MaterialPageRoute(
    //                               builder: (context) => OfflinePage(),
    //                             ),
    //                           );
    //                           // Navigator.pushAndRemoveUntil(
    //                           //     context,
    //                           //     PageTransition(
    //                           //         duration: Duration(milliseconds: 200),
    //                           //         curve: Curves.bounceInOut,
    //                           //         type: PageTransitionType.fade,
    //                           //         child: VideoScreenOffline()),
    //                           //     (route) => false);
    //                         },
    //                         child: Container(
    //                           decoration: BoxDecoration(
    //                               borderRadius: BorderRadius.circular(30),
    //                               gradient: gradient),
    //                           child: Padding(
    //                             padding: const EdgeInsets.all(14.0),
    //                             child: Text(
    //                               'Go offline',
    //                               style: TextStyle(
    //                                   fontFamily: 'SemiBold',
    //                                   fontSize: 18,
    //                                   color: Colors.black),
    //                             ),
    //                           ),
    //                         ),
    //                       ),
    //                     ],
    //                   )
    //                 ],
    //               )
    //             ],
    //           ),
    //         ),
    //       ),
    //     ),
    //   );

    //   // show the dialog
    //   showDialog(
    //     barrierColor: Colors.black38,
    //     barrierDismissible: false,
    //     context: context,
    //     builder: (BuildContext context) {
    //       return alert;
    //     },
    //   );
    // }

    // final StreamSubscription<InternetConnectionStatus> listener =
    //     InternetConnectionChecker().onStatusChange.listen(
    //   (InternetConnectionStatus status) {
    //     switch (status) {
    //       case InternetConnectionStatus.connected:
    //         print('Data connection is available.');
    //         // showToast("You're now connected");
    //         break;
    //       case InternetConnectionStatus.disconnected:
    //         print('You are disconnected from the internet.');
    //         // Future.delayed(Duration(seconds: 10), () {
    //         //   showNoInternet();
    //         // });
    //         // showToast("You are disconnected from the internet");
    //         break;
    //     }
    //   },
    // );
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: StyledToast(
        locale: const Locale('en', 'US'),
        textStyle: TextStyle(
            fontSize: 16.0, color: Colors.white, fontFamily: 'Medium'),
        backgroundColor: Colors.black,
        borderRadius: BorderRadius.circular(30.0),
        textPadding: EdgeInsets.symmetric(horizontal: 17.0, vertical: 10.0),
        toastAnimation: StyledToastAnimation.slideFromBottom,
        reverseAnimation: StyledToastAnimation.slideToBottom,
        startOffset: Offset(0.0, 3.0),
        reverseEndOffset: Offset(0.0, 3.0),
        duration: Duration(seconds: 3),
        animDuration: Duration(milliseconds: 500),
        alignment: Alignment.center,
        toastPositions: StyledToastPosition.bottom,
        curve: Curves.bounceIn,
        reverseCurve: Curves.bounceOut,
        dismissOtherOnShow: true,
        fullWidth: false,
        isHideKeyboard: false,
        isIgnoring: true,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_)=>ChatScreenNotifier(),child: ChatScreen()),
            ChangeNotifierProvider.value(value: UserProvider.initialize()),
            ChangeNotifierProvider.value(value: AppProvider()),
            StreamProvider<List<CourseDetails>>.value(
              value: DatabaseServices().courseDetails,
              initialData: [],
            ),
            StreamProvider<List<VideoDetails>>.value(
              value: DatabaseServices().videoDetails,
              initialData: [],
            ),
          ],

          // builder: (context,child)
          // {
          //   return MediaQuery(
          //     child: child!,
          //     data: MediaQuery.of(context).copyWith(textScaleFactor: 1.15),
          //   );
          // },

          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'CloudyML',
            builder: (BuildContext context, Widget? widget) {
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                return Container();
              };
              return MediaQuery(
                child: widget!,
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.15),
              );
            },
            theme: ThemeData(
              primarySwatch: Colors.blue,
              // textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            ),
            home: splash(),
            routes: {
              "account": (_) => MyAccountPage(),
              "courses": (_) => HomeScreen(),
            },
          ),
        ),
      ),
    );
  }
}

class ScreenController extends StatelessWidget {
  const ScreenController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
