import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/screens/groups_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';



class LocalNotificationService{

  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static final onNotifications=BehaviorSubject<String?>();
  static void initialize(){
    // initializationSettings  for Android
    const InitializationSettings initializationSettings =
    InitializationSettings(android: AndroidInitializationSettings("@mipmap/ic_launcher"),);
    _notificationsPlugin.initialize(initializationSettings,onSelectNotification: (payload) async{
      print("Hello");
      onNotifications.add(payload);
    });
  }

  // static void NavigateTo()
  // {
  //   Navigator.push(context, MaterialPageRoute(builder: (context)=>GroupsList()));
  // }

  static display(RemoteMessage message,courseName,id,count)async{
    try {
      FirebaseFirestore _firestore=FirebaseFirestore.instance;
      // final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
            "CloudyML",
            "CloudyMLchannel",
            importance: Importance.max,
            priority: Priority.high,
            color: Colors.green,
            playSound: true,
            channelDescription: 'Chat Notification'
        ),
      );
      String imageUrl = message.notification!.android!.imageUrl??'';
      String NewMessage = count==1?" new message":" new messages";
      // var data = {"ID":id,"student_id":FirebaseAuth.instance.currentUser!.uid,"CourseName":courseName};
      await _notificationsPlugin.show(
        id,
        message.notification!.title.toString()+"    "+count.toString()+NewMessage,
        message.notification!.body,
        notificationDetails,
        //payload: message.data['_id'],
      );
      // return data;
      // _firestore.collection('Notifications')
      //     .add({
      //       'title':message.notification!.title,
      //       'description':message.notification!.body,
      //       'icon':imageUrl
      // });
    } on Exception catch (e) {
      print(e);
      // return {};
    }
  }

  static void createanddisplaynotification(RemoteMessage message) async {
    try {
      FirebaseFirestore _firestore = FirebaseFirestore.instance;
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
            "CloudyML",
            "CloudyMLchannel",
            importance: Importance.max,
            priority: Priority.high,
            color: Colors.green,
            playSound: true,
            channelDescription: 'Chat Notification'
        ),
      );
      String imageUrl = message.notification!.android!.imageUrl??'';

      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        //payload: message.data['_id'],
      );
      // _firestore.collection('Notifications')
      //     .add({
      //       'title':message.notification!.title,
      //       'description':message.notification!.body,
      //       'icon':imageUrl
      // });
    } on Exception catch (e) {
      print(e);
    }
  }


  //This code is for in app notification for performing any task
  static Future showNotificationfromApp({int id=0,String? title,String? body,String? payload,}) async{
    return _notificationsPlugin.show(
        id,
        title,
        body,
        await notificationDetailslocal(),
        payload: payload
    );
  }

  // static Future init({bool initSchedule=false}) async{
  //   await _notificationsPlugin.initialize(initializationSettings,onSelectNotification: (payload)async{
  //
  //   });
  // }

  static Future notificationDetailslocal() async{
    var bigPicture=BigPictureStyleInformation(
        DrawableResourceAndroidBitmap("homeimage"),
        largeIcon: DrawableResourceAndroidBitmap("dp_png"),
        contentTitle: "CloudyML",
        summaryText: "CloudyML",
        htmlFormatContent: true,
        htmlFormatContentTitle: true
    );
    return NotificationDetails(
        android: AndroidNotificationDetails(
            "CloudyML",
            "CloudyMLchannel",
            styleInformation: bigPicture,
            importance: Importance.max,
            priority: Priority.high
        )
    );
  }
}