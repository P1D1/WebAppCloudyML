import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloudyml_app2/Providers/chat_screen_provider.dart';
import 'package:cloudyml_app2/fun.dart';
import 'package:cloudyml_app2/helpers/file_handler.dart';
import 'package:cloudyml_app2/widgets/audio_msg_tile.dart';
import 'package:cloudyml_app2/widgets/bottom_sheet.dart';
import 'package:cloudyml_app2/widgets/file_msg_tile.dart';
import 'package:cloudyml_app2/widgets/image_msg_tile.dart';
import 'package:cloudyml_app2/widgets/message_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/screens/groups_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ChatScreen extends StatefulWidget {
  // const ChatScreen({Key? key, this.groupData, this.userData}) : super(key:key);
  final groupData;
  final userData;
  String? groupId;

  ChatScreen({
    Key? key,
    this.groupData,
    this.groupId,
    this.userData,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
//....................VARIABLES.................................

  List<DocumentSnapshot> listOfDocumentSnapshot = [];

  DocumentSnapshot<Map<String, dynamic>>? _lastDocument1;

  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  TextEditingController _message = TextEditingController();

  // FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  File? pickedFile;

  String? filename;

  Uint8List? uploadedFile;

  String? pickedFileName;

  Directory? appStorage;

  int count = 0;

  ScrollController _scrollController = ScrollController();

  final StreamController<List<DocumentSnapshot>> _chatController =
      StreamController<List<DocumentSnapshot>>.broadcast();

  List<List<DocumentSnapshot>> _allPagedResults = [<DocumentSnapshot>[]];

  static const int chatLimit = 10;

  bool _hasMoreData = true;

  Stream<List<DocumentSnapshot>> listenToChatsRealTime() {
    _getChats();
    
    return _chatController.stream;
  }

  // bool textFocusCheck = false;

  Record record = Record();
  bool isRecording = false;
  bool _showbadge = false;

//...............FUNCTIONS.........................

  //getting chats with pagination logic

  //Global variables to hold tagImage and tagName of tag
  List<String> tagImages = [];
  List<String> tagNames = [];

  ///This mehtod adds Images and Names to be used for to [tagNames] and [tagImages]
  ///Group members for UI of list of tags
  Future<void> addTagProperties() async {
    //Take list User id of all mentors
    List tagUserId = widget.groupData['mentors'];
    //Take user id of student
    tagUserId.add(widget.groupData['student_id']);
    //Loop over list of member ids in tagUserId to fetch Name and Image of Respective member
    for (var member in tagUserId) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(member)
          .get()
          .then((value) {
        if (value.data() != null) {
          //Add member name and image to [tagNames] and [tagImages] only if does not contain already and
          //Only If member is not currentUser in FirebaseAuth
          if (!tagNames.contains(value.data()!['name']) &&
              value.data()!['name'] != widget.userData["name"]) {
            tagNames.add(value.data()!['name']);
            tagImages.add(value.data()!['image']);
          }
        }
      });
    }
  }

  //Flag used to make the list of tags visible and invisible
  bool shouldShowTags = false;

  ///This method inserts a text into textfield and moves cursor at end
  void _insertText(String inserted) {
    final text = _message.text;
    final selection = _message.selection;
    final newText = text.replaceRange(selection.start, selection.end, inserted);
    _message.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.baseOffset + inserted.length,
      ),
    );
  }

  ///This method returns widget that represents list of tags to choose from
  Widget buildTags(BuildContext context, double height, double width) {
    final provider = Provider.of<ChatScreenNotifier>(context, listen: false);
    return Container(
      height: height * 0.25,
      width: width * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border.all(
          color: Colors.grey,
          width: 0.1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: ListView.builder(
          itemCount: tagNames.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/user.jpg'),
                foregroundImage: NetworkImage(tagImages[index]),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(tagNames[index]), Divider()],
              ),
              minVerticalPadding: 0,
              onTap: () {
                //If tapped on particular [listTile] it inserts tag of that member in textField
                _insertText('${tagNames[index]} ');
                //And Hides the list of tags
                setState(() {
                  currentTag = '@${tagNames[index]}';
                });
                provider.showTags(false);
              },
            );
          },
        ),
      ),
    );
  }

  String currentTag = '';

  void _getChats() {
    count = 0;
    var pageChatQuery = _firestore
        .collection("groups")
        .doc(widget.groupData!.id)
        .collection("chats")
        .orderBy("time", descending: true)
        .limit(chatLimit);

    if (_lastDocument != null) {
      pageChatQuery = pageChatQuery.startAfterDocument(_lastDocument!);
    }

    if (!_hasMoreData) return;

    var currentRequestIndex = _allPagedResults.length;
    pageChatQuery.snapshots().listen(
      (snapshot) {
        if (snapshot.docs.isNotEmpty) {
          var generalChats = snapshot.docs.toList();
          var pageExists = currentRequestIndex < _allPagedResults.length;

          if (pageExists) {
            _allPagedResults[currentRequestIndex] = generalChats;
          } else {
            _allPagedResults.add(generalChats);
          }

          var allChats = _allPagedResults.fold<List<DocumentSnapshot>>(
              <DocumentSnapshot>[],
              (initialValue, pageItems) => initialValue..addAll(pageItems));

          _chatController.add(allChats);

          if (currentRequestIndex == _allPagedResults.length - 1) {
            _lastDocument = snapshot.docs.last;
          }

          _hasMoreData = generalChats.length == chatLimit;
        }
      },
    );
  }

  // _getChats()
  // async{
  //   if(_lastDocument1!=null)
  //   {
  //     await  FirebaseFirestore.instance
  //         .collection("groups")
  //         .doc(widget.groupData!.id)
  //         .collection("chats")
  //         .orderBy("time", descending: true).startAfterDocument(_lastDocument1!).limit(chatLimit).get().then((value) {
  //       print("Value ==== ${value.docs.first}");
  //       for(var i in value.docs)
  //       {
  //         listOfDocumentSnapshot.add(i);
  //       }
  //       print(listOfDocumentSnapshot);
  //     });
  //   }
  //   else
  //   {
  //     await  FirebaseFirestore.instance
  //         .collection("groups")
  //         .doc(widget.groupData!.id)
  //         .collection("chats")
  //     // .startAfterDocument(_lastDocument1!)
  //         .orderBy("time", descending: true).limit(chatLimit).get().then((value) {
  //       print("Value ==== ${value.docs.first}");
  //       for(var i in value.docs)
  //       {
  //         listOfDocumentSnapshot.add(i);
  //       }
  //       print(listOfDocumentSnapshot);
  //     });
  //   }
  //
  //   _lastDocument1 = listOfDocumentSnapshot.last as DocumentSnapshot<Map<String, dynamic>>?;
  //   _chatController.add(listOfDocumentSnapshot);
  //   print("data = == ");
  //   // print(data.runtimeType);
  //   // print(await data.toString()+"----------");
  //
  // }

  // Future getPicture(type) async {
  //   //to get the image from galary
  //   ImagePicker _picker = ImagePicker();
  //
  //   await _picker.pickImage(
  //       source: ImageSource.gallery,imageQuality: 60)
  //       .catchError((onError)
  //   { Fluttertoast.showToast(msg: onError.toString());}).then((xFile) async {
  //     if (xFile != null) {
  //
  //       pickedFile = File(xFile.path);
  //       pickedFileName = xFile.name.toString();
  //       final String filepath = path.basename(pickedFile.toString());
  //
  //       var storageRef = FirebaseStorage.instance
  //           .ref()
  //           .child('test_developer')
  //           .child(pickedFileName!);
  //
  //       var sentData = await FirebaseFirestore.instance
  //           .collection("groups")
  //           .doc(widget.groupData!.id)
  //           .collection("chats")
  //           .add({
  //         "link": "",
  //         "message": pickedFileName,
  //         "sendBy": widget.userData["name"],
  //         "time": FieldValue.serverTimestamp(),
  //         "type": "image",
  //       });
  //
  //       await filterMentorStudentNotification(filepath);
  //
  //       final UploadTask uploadTask = storageRef.putFile(pickedFile!);
  //
  //       final TaskSnapshot downloadUrl = await uploadTask;
  //       final String attachUrl = (await downloadUrl.ref.getDownloadURL());
  //
  //       await sentData.update({"link": attachUrl});
  //
  //     }
  //   });
  // }


  Future getImage(BuildContext context, type) async {

    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowCompression: true,
        withData: true,
      );
    } catch (e) {
      print(e.toString());
    }
    if (result != null && result.files.isNotEmpty) {
      try {
        Uint8List? uploadFile = result.files.single.bytes;
        uploadedFile = uploadFile;
        final String filepath = path.basename(uploadFile.toString());
        String pickedFileName = result.files.first.name;

        var storageRef = FirebaseStorage.instance
            .ref()
            .child('test_developer')
            .child(pickedFileName);

        var sentData = await FirebaseFirestore.instance
            .collection("groups")
            .doc(widget.groupData!.id)
            .collection("chats")
            .add({
          "link": "",
          "message": pickedFileName,
          "sendBy": widget.userData["name"],
          "time": FieldValue.serverTimestamp(),
          "type": "image",
        });

        await filterMentorStudentNotification(filepath);
        final UploadTask uploadTask = storageRef.putData(uploadFile!);

        final TaskSnapshot downloadUrl = await uploadTask;
        final String attachUrl = (await downloadUrl.ref.getDownloadURL());

        await sentData.update({"link": attachUrl});

        print('link is here: $attachUrl');

      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
        print(e.toString());
      }
    }
  }



  //file picker logic
  Future getFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File a = File(result.files.single.path.toString());
      pickedFile = a;
      pickedFileName = result.names[0].toString();
      uploadFile("file");
    }
  }

  //storing file/image to firestore database
  Future uploadFile(type) async {
    try {
      var sentData = await _firestore
          .collection("groups")
          .doc(widget.groupData!.id)
          .collection("chats")
          .add({
        "link": "",
        "message": pickedFileName,
        "sendBy": widget.userData["name"],
        "time": FieldValue.serverTimestamp(),
        "type": type == "image"
            ? "image"
            : type == "audio"
                ? "audio"
                : "file",
      });
      var ref = FirebaseStorage.instance
          .ref()
          .child(type == "image"
              ? "images"
              : type == "audio"
                  ? "aduios"
                  : "files")
          .child(pickedFileName!);
      //To bring latest msg on top
      // await _firestore.collection('groups').doc(widget.groupData!["id"]).update(
      //   {'time': FieldValue.serverTimestamp()},
      // );

      await filterMentorStudentNotification(pickedFileName);
      var uploadTask = await ref.putFile(pickedFile!);

      String fileUrl = await uploadTask.ref.getDownloadURL();

      await sentData.update({"link": fileUrl});
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  //storing message to firestore database
  void onSendMessage() async {
    var messages = _message.text;
    _message.clear();
    //to send the text to server
    if (messages.isNotEmpty) {
      Map<String, dynamic> message = {
        "message": messages,
        "sendBy": widget.userData["name"],
        "type": "text",
        "time": FieldValue.serverTimestamp(),
        "role": widget.userData["role"],
      };

      await _firestore
          .collection("groups")
          .doc(widget.groupData!.id)
          .collection("chats")
          .add(message);
      print("GroupId = ${widget.groupId}");
      await _firestore
          .collection("groups")
          .doc(widget.groupId)
          .update({"time": FieldValue.serverTimestamp()});
      print('count is-------$count');

      // await stream();
      // setState(() {
      //   textFocusCheck = false;
      // });

      await filterMentorStudentNotification(messages);
    }
  }

  void startRecording() async {
    print("REcording....");
    if (await Record().hasPermission()) {
      isRecording = true;
      await record.start(
        path: appStorage!.path.toString() +
            "/audio_${DateTime.now().millisecondsSinceEpoch}.m4a",
        encoder: AudioEncoder.AAC,
        bitRate: 128000,
        samplingRate: 44100,
      );
    }
  }

  //stop recording and send audio message to firestore database
  void stopRecording() async {
    if (isRecording) {
      var filePath = await Record().stop();
      print("The audio file path is $filePath");
      pickedFile = File(filePath!);
      pickedFileName = filePath.split("/").last;
      isRecording = false;
      uploadFile("audio");
    }
  }

  //stop recording and delete recorde file
  void cancelRecording() async {
    if (isRecording) {
      var filePath = await Record().stop();
      var recordedFile = File(filePath.toString());
      if (await recordedFile.exists()) {
        await recordedFile.delete();
      }
      isRecording = false;
    }
  }

  //on record show bottom modal and send audio message
  void onSendAudioMessage() async {
    final size = MediaQuery.of(context).size;
    startRecording();
    showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(50),
          ),
        ),
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: StatefulBottomSheet(
              size: size,
              startRecording: startRecording,
              stopRecording: stopRecording,
              cancelRecording: cancelRecording,
            ),
          );
        });
    //To bring latest msg on top
    // await _firestore
    //     .collection('groups')
    //     .doc(widget.groupData!["id"])
    //     .update({'time': FieldValue.serverTimestamp()});
  }

  //getting path to app's internal storage
  // Future getStoragePath() async {
  //   var s;
  //   if (await Permission.storage.request().isGranted) {
  //     s = await getExternalStorageDirectory();
  //   }
  //   setState(() {
  //     appStorage = s;
  //   });
  // }

  // void showTags() {
  //   _message.text;
  // }

  // getDetailsOfToken()
  // async {
  //   final data1 = FirebaseFirestore.instance.collection("Users").doc("4tUBmnt068e1688kfrOCRhlNHo52").set(
  //     {"token":await FirebaseMessaging.instance.getToken()},SetOptions(merge: true)
  //   );
  //
  //   final data = FirebaseFirestore.instance.collection("Users").doc("aJSYa3RkWQTzyA0TnyLhh72MzZc2");
  //
  //   final response = data.get().then((DocumentSnapshot doc){
  //     final data2 = doc.data() as Map<String,dynamic>;
  //     print("data = $data2");
  //   });
  // }

  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool removeNotificationOnChatScreenOn = false;
  final myBox = Hive.box('myBox');
  @override
  void initState() {
    removeNotificationOnChatScreenOn = true;
    // TODO: implement initState
    // _message.addListener();

    // final InitializationSettings initializationSettings =
    // InitializationSettings(
    //     android: AndroidInitializationSettings("@mipmap/ic_launcher"));
    // _flutterLocalNotificationsPlugin.initialize(initializationSettings,onSelectNotification: (payload)async{
    //   print("Hello notify");
    //   Navigator.of(context).push(MaterialPageRoute(builder: (context)=>GroupsList()));
    // });
    RemoveNotificationChatScreen();
    print("GroupData = ${widget.groupData["student_id"]}");
    print("USerData =  ${widget.userData["id"]}");
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              (_scrollController.position.maxScrollExtent) &&
          !_scrollController.position.outOfRange) {
        _getChats();
      }
    });

    // FirebaseMessaging.instance.getInitialMessage().then((message) {
    //   if(_message!=null)
    //     {
    //       Navigator.push(context,
    //           MaterialPageRoute(builder: (context) => GroupsList()));
    //     }
    // });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("MEssageChat screen");
      print(widget.groupData!["name"]);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Navigation");
      if (message.notification!.body != null) {
        print("Navigation");
        Navigator.pop(context);
      }
    });

    super.initState();
  }

  RemoveNotificationChatScreen() async {
    var dataValues = await myBox.values;
    for (var i in dataValues) {
      try {
        if (i["DocumentId"].toString() == widget.groupId.toString()) {
          await removeNotification(i["ID"]);
        }
      } catch (err) {
        print(err);
      }
    }
  }

  List? groupsList;

  static const int documentLimit = 30;
  // _getGroupDetails() async {
  //
  //   QuerySnapshot<Map<String, dynamic>> querySnapshot =
  //   widget.userData!['role'] == 'student'
  //       ? await _firestore
  //       .collection("groups")
  //       .where("student_id", isEqualTo: _auth.currentUser!.uid)
  //   // .orderBy('sr', descending: true)
  //       .limit(documentLimit)
  //       .get()
  //       .then((value) => value)
  //       : await _firestore
  //       .collection("groups")
  //   // .where("mentors", arrayContains: _auth.currentUser!.uid)
  //       .orderBy('time', descending: true)
  //       .limit(documentLimit)
  //       .get()
  //       .then((value) => value);
  //   groupsList = querySnapshot.docs
  //       .map((doc) => {
  //     "id": doc.id,
  //     "data": doc.data(),
  //   })
  //       .toList();
  //   // getchatcount(querySnapshot.docs
  //   //     .map((doc) => {
  //   //           "id": doc.id,
  //   //           "data": doc.data(),
  //   //         })
  //   //     .toList());
  //   _lastDocument = querySnapshot.docs.last;
  //
  // }

  Map? userData = {};

  removeNotification(ID) async {
    await _flutterLocalNotificationsPlugin.cancel(ID);
    await myBox.delete(ID);
  }

  filterMentorStudentNotification(message) async {
    var mentorList = widget.groupData["mentors"];
    print(mentorList);

    if (widget.userData["role"] == "mentor") {
      mentorList.remove(widget.userData["id"]);
      mentorList.add(widget.groupData["student_id"]);
    }
    await sendNotification(mentorList, message);
  }

  sendNotification(List listOfDocumentUsers, message) async {
    for (var documentId in listOfDocumentUsers) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(documentId)
          .get()
          .then(
        (value) async {
          try {
            const SERVER_API_KEY =
                "AAAAD5zkKfo:APA91bE5z1j6YGz8xZEAHqAaqI8YNE6lZ6oIEfa8ojnp-bk-Ai2dixXDZ1IgZF-VaKsjQ_3MDFSug0hC9MlyIyXJIUP21mCFlFg8wuSqtBzRtEN9mzALmEN0f0eJGn9xWsISMt_W88pR";
            // print("value = ${value["token"]}");
            var headers = {
              'Authorization': 'key=$SERVER_API_KEY',
              'Content-Type': 'application/json'
            };
            var request = await http.Request(
                'POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
            request.body = json.encode({
              "to": value["token"],
              "notification": {
                "body": message,
                "title": widget.userData["name"]
              },
              "data": {
                "DocumentId": widget.groupId.toString(),
                "SenderId": FirebaseAuth.instance.currentUser!.uid.toString()
              }
            });
            request.headers.addAll(headers);
            http.StreamedResponse response = await request.send();
            if (response.statusCode == 200) {
              print(await response.stream.bytesToString());
            } else {
              print(response.reasonPhrase);
            }
            print("Send");
          } catch (err) {
            print("Error");
          }
        },
      );
    }
  }

  // sendNotification(message,senderId)
  // async{
  //   var Id = await _firestore
  //       .collection('groups')
  //       .doc(
  //       widget.groupData!.id
  //   );
  //   var responseData;
  //   final response = await Id.get().then((DocumentSnapshot doc){
  //     responseData = doc.data() as Map<String,dynamic>;
  //   });
  //   print(response);
  //   var listInstance = [];
  //   var list = [];
  //   for(int i=0;i<responseData["mentors"].length;i++)
  //   {
  //     var res = FirebaseFirestore.instance.collection("Users").doc(responseData["mentors"][i]).get();
  //     listInstance.add(res);
  //   }
  //
  //   if(responseData["student_id"]!=FirebaseAuth.instance.currentUser!.uid)
  //   {
  //     print("Mentor message===================");
  //     await sendNotificationToStudentsMentors(responseData,list,message,senderId);
  //   }
  //   else {
  //     print("student message -------------------------");
  //     await sendNotificationToAllMentors(
  //         listInstance, responseData, list, message, senderId,false);
  //
  //     // await sendAPI(list, message, senderId);
  //   }
  // }

  // sendNotificationToStudentsMentors(responseData,list,message,senderId)
  // async{
  //   var senderId = FirebaseAuth.instance.currentUser!.uid;
  //   var listInstance = [];
  //   for(int i=0;i<responseData["mentors"].length;i++)
  //   {
  //     var res = await FirebaseFirestore.instance.collection("Users").doc(responseData["mentors"][i]).get();
  //     if(responseData["mentors"][i]!=senderId){
  //       listInstance.add(res);
  //     }
  //     if(i==responseData["mentors"].length-1)
  //     {
  //       var res = await FirebaseFirestore.instance.collection("Users").doc(responseData["student_id"]).get();
  //       sleep(Duration(milliseconds: 100));
  //       listInstance.add(res);
  //     }
  //     sleep(Duration(milliseconds: 100));
  //   }
  //   print("listinstance+++++++++++++++++++${listInstance}");
  //   await sendNotificationToAllMentors(listInstance, responseData, list, message, senderId,true);
  // }

  // sendNotificationToAllMentors(listInstance,responseData,listOfTokenId,message,senderId,expression)
  // async{
  //
  //   print("responsedat = =====-----${responseData["student_id"]}");
  //
  //
  //   const SERVER_API_KEY = "AAAAD5zkKfo:APA91bE5z1j6YGz8xZEAHqAaqI8YNE6lZ6oIEfa8ojnp-bk-Ai2dixXDZ1IgZF-VaKsjQ_3MDFSug0hC9MlyIyXJIUP21mCFlFg8wuSqtBzRtEN9mzALmEN0f0eJGn9xWsISMt_W88pR";
  //   int j=0;
  //
  //   if(expression)
  //   {
  //     for(j=0;j<listInstance.length;j++)
  //     {
  //       var getData = listInstance[j].data();
  //       print(getData);
  //       if(getData["token"]!=null)
  //       {
  //         listOfTokenId.add(getData["token"]);
  //       }
  //     }
  //   }
  //   else
  //   {
  //     for(j=0;j<listInstance.length;j++)
  //     {
  //
  //       await listInstance[j].then((DocumentSnapshot doc) {
  //         responseData = doc.data() as Map<String, dynamic>;
  //         if(responseData["token"]!=null)
  //         {
  //           listOfTokenId.add(responseData["token"]);
  //         }
  //       });
  //
  //     }
  //   }
  //
  //
  //
  //   print("User Id ===================== ${FirebaseAuth.instance.currentUser!.uid}");
  //
  //
  //   print("length = ${listOfTokenId.length}");
  //   if(listOfTokenId.length>0)
  //   {
  //     print(widget.groupData!["name"]);
  //     int j=0;
  //     while(j<listOfTokenId.length)
  //     {
  //       try{
  //         var headers = {
  //           'Authorization': 'key=$SERVER_API_KEY',
  //           'Content-Type': 'application/json'
  //         };
  //         var request = await http.Request('POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
  //         request.body = json.encode({
  //           "to": listOfTokenId[j],
  //           "notification": {
  //             "body": message,
  //             "title": widget.userData["name"]
  //           },
  //           "data":{
  //             "DocumentId":widget.groupId.toString(),
  //             "SenderId":FirebaseAuth.instance.currentUser!.uid.toString()
  //           }
  //         });
  //         request.headers.addAll(headers);
  //
  //         http.StreamedResponse response = await request.send();
  //
  //         if (response.statusCode == 200) {
  //           sleep(Duration(milliseconds: 100));
  //           j++;
  //           print(await response.stream.bytesToString());
  //         }
  //         else {
  //           sleep(Duration(milliseconds: 100));
  //           j++;
  //           print(response.reasonPhrase);
  //         }
  //         print("Send");
  //       }
  //       catch(e)
  //       {
  //         print(e);
  //         break;
  //       }
  //     }
  //   }
  // }

  String reverseString(String str) {
    const listOfMonths = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    String reverseString = "";
    List list = [];
    for (int i = 0; i < str.length; i++) {
      if (str[i] == "-" || i == str.length - 1) {
        i == str.length - 1 ? reverseString += str[i] : null;
        list.add(reverseString);
        reverseString = "";
      } else {
        reverseString += str[i];
      }
    }

    reverseString = "";
    reverseString =
        list[2] + " " + listOfMonths[int.parse(list[1]) - 1] + " " + list[0];
    return reverseString;
  }

  Widget showDateInChatScreen(String dateString) {
    return Center(
        child: Container(
      margin: EdgeInsets.only(top: 5, bottom: 3),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Color(0xFF7860DC), borderRadius: BorderRadius.circular(20)),
      child: Text(
        "$dateString",
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ));
  }

  // sendAPI(list,message,senderId)
  // async{
  //   for(int k=0;k<list.length;k++)
  //   {
  //     try{
  //       var headers = {
  //         'Authorization': 'key=AAAAD5zkKfo:APA91bE5z1j6YGz8xZEAHqAaqI8YNE6lZ6oIEfa8ojnp-bk-Ai2dixXDZ1IgZF-VaKsjQ_3MDFSug0hC9MlyIyXJIUP21mCFlFg8wuSqtBzRtEN9mzALmEN0f0eJGn9xWsISMt_W88pR',
  //         'Content-Type': 'application/json'
  //       };
  //       var request = await http.Request('POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
  //       request.body = json.encode({
  //         "to": list[k],
  //         "notification": {
  //           "body": message,
  //           "title": senderId
  //         }
  //       });
  //       request.headers.addAll(headers);
  //
  //       http.StreamedResponse response = await request.send();
  //
  //       if (response.statusCode == 200) {
  //         print(await response.stream.bytesToString());
  //       }
  //       else {
  //         print(response.reasonPhrase);
  //       }
  //
  //     }
  //     catch(e)
  //     {
  //       print(e);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final providerChatScreenNotifier =
        Provider.of<ChatScreenNotifier>(context, listen: false);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final size = MediaQuery.of(context).size;
    print("user name is ${widget.userData}");
    print("USer = ${widget.groupData.id}");
    return WillPopScope(
      onWillPop: () async {
        removeNotificationOnChatScreenOn = false;
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF7860DC),
              //     gradient: LinearGradient(
              // begin: Alignment.bottomLeft,
              // end: Alignment.topRight,
              // colors: [Color(0xFF7860DC),Color(0xFF7860DC)]),
            ),
          ),

          // backgroundColor: Colors.purple[800],
          elevation: 0,
          title: Container(
            padding: EdgeInsets.only(left: 0),
            child: Row(
              children: [
                GestureDetector(
                    onTap: () {
                      removeNotificationOnChatScreenOn = false;
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.arrow_back),
                    )),
                CircleAvatar(
                  radius: 22,
                  backgroundImage:
                      CachedNetworkImageProvider(widget.groupData!["icon"]),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  width: width * 0.6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: width * 0.52,
                            child: Text(
                              widget.groupData!["name"],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
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
          // actions: [
          //   PopupMenuButton(
          //     itemBuilder: (context) {
          //       return [
          //         PopupMenuItem<int>(
          //           value: 0,
          //           child: Container(
          //             width: width * 0.5,
          //             child: const Text("Group Info"),
          //           ),
          //         ),
          //       ];
          //     },
          //     onSelected: (value) {
          //       if (value == 0) {
          //         print(widget.groupData);
          //         Navigator.push(
          //           context,
          //           CupertinoPageRoute(
          //             builder: (_) =>
          //                 GroupInfoScreen(groupData: widget.groupData!),
          //           ),
          //         );
          //       }
          //     },
          //   )
          // ],
        ),
        body: appStorage != null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                reverse: true,
                child: Column(
                  children: [
                    //Chats container
                    Container(
                      height: size.height / 1.33,
                      width: size.width,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/g8.png'),
                            opacity: 0.16,
                            fit: BoxFit.cover),
                      ),
                      child: StreamBuilder<List<DocumentSnapshot>>(
                        stream: listenToChatsRealTime(),
                        builder: (context, snapshot) {
                          if (snapshot.data![0]["type"] == "image") {
                            print("link is here: ${snapshot.data![0]["link"]}");
                          }

                          if (snapshot.connectionState ==
                                  ConnectionState.waiting ||
                              snapshot.connectionState ==
                                  ConnectionState.none) {
                            return snapshot.hasData
                                ? Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    padding:
                                    EdgeInsets.fromLTRB(5, 5, 5, 5),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,

                                      //DecorationImage
                                      // border: Border.all(
                                      //   // color: Colors.green,
                                      //   width: 8,
                                      // ), //Border.all
                                      borderRadius:
                                      BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey,
                                          offset: const Offset(
                                            1.0,
                                            1.0,
                                          ), //Offset
                                          blurRadius: 2.0,
                                          spreadRadius: 2.0,
                                        ), //BoxShadow
                                        BoxShadow(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                          offset: const Offset(0.0, 0.0),
                                          blurRadius: 0.0,
                                          spreadRadius: 0.0,
                                        ), //BoxShadow
                                      ],
                                    ),
                                    margin:
                                    EdgeInsets.fromLTRB(25, 0, 25, 0),
                                    child: chat()
                                  //  Text(
                                  // 'You can ask assignment related doubts here 6pm- midnight.(Indian standard time)\nour mentors:-\n6:00pm-7:30pm - Rahul\n7:30pm-midnight - Harsh'),
                                )
                                // Center(
                                //     child: Text("Start a Conversation."),
                                //   ),
                              ],
                            ) : const Center(
                                    child: CircularProgressIndicator(),
                            );
                          } else {
                            if (snapshot.data != null) {
                              print("MessageDataa = = ${snapshot.data}");

                              return Stack(
                                children: [
                                  ListView.builder(
                                    reverse: true,
                                    controller: _scrollController,
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      print(
                                          "currentTag = ${currentTag.toString()}");
                                      Map<String, dynamic> map =
                                          // messageData =
                                          snapshot.data![index].data()
                                              as Map<String, dynamic>;

                                      return Column(
                                        children: [
                                          index != snapshot.data!.length - 1
                                              ? snapshot.data![index]["time"]
                                                          .toDate()
                                                          .toString()
                                                          .substring(0, 10) !=
                                                      snapshot.data![index + 1]
                                                              ["time"]
                                                          .toDate()
                                                          .toString()
                                                          .substring(0, 10)
                                                  ? snapshot.data![index]["time"]
                                                              .toDate()
                                                              .toString()
                                                              .substring(
                                                                  0, 10) ==
                                                          DateTime.now().subtract(Duration(days: 1)).toString().substring(
                                                              0, 10)
                                                      ? showDateInChatScreen(
                                                          "yesterday")
                                                      : snapshot.data![index]["time"]
                                                                  .toDate()
                                                                  .toString()
                                                                  .substring(
                                                                      0, 10) ==
                                                              DateTime.now()
                                                                  .toString()
                                                                  .substring(0, 10)
                                                          ? showDateInChatScreen("today")
                                                          : showDateInChatScreen(reverseString(snapshot.data![index]["time"].toDate().toString().substring(0, 10)))
                                                  : SizedBox()
                                              : snapshot.data![index]["time"].toDate().toString().substring(0, 10) == DateTime.now().subtract(Duration(days: 1)).toString().substring(0, 10)
                                                  ? showDateInChatScreen("yesterday")
                                                  : snapshot.data![index]["time"].toDate().toString().substring(0, 10) == DateTime.now().toString().substring(0, 10)
                                                      ? showDateInChatScreen("today")
                                                      : showDateInChatScreen(reverseString(snapshot.data![index]["time"].toDate().toString().substring(0, 10))),
                                          messages(
                                            size,
                                            map,
                                            context,
                                            appStorage,
                                            currentTag,
                                          )
                                        ],
                                      );
                                    },
                                  ),
                                  // shouldShowTags
                                  //     ? Positioned(
                                  //   bottom: 0,
                                  //   child: FutureBuilder(
                                  //     future: addTagProperties(),
                                  //     builder: ((context, snapshot) {
                                  //       if (ConnectionState.done ==
                                  //           snapshot.connectionState) {
                                  //         return buildTags(
                                  //           context,
                                  //           height,
                                  //           width,
                                  //         );
                                  //       } else {
                                  //         return Container(
                                  //           height: height * 0.25,
                                  //           width: width * 0.8,
                                  //           decoration: BoxDecoration(
                                  //             color: Colors.white,
                                  //             borderRadius:
                                  //             BorderRadius.only(
                                  //               topLeft:
                                  //               Radius.circular(20),
                                  //               topRight:
                                  //               Radius.circular(20),
                                  //             ),
                                  //             border: Border.all(
                                  //               color: Colors.grey,
                                  //               width: 0.1,
                                  //             ),
                                  //           ),
                                  //           child: Padding(
                                  //             padding:
                                  //             const EdgeInsets.all(20),
                                  //             child: ClipRRect(
                                  //               borderRadius:
                                  //               BorderRadius.circular(
                                  //                   20),
                                  //               child: Lottie.asset(
                                  //                   'assets/load-shimmer.json',
                                  //                   fit: BoxFit.fill),
                                  //             ),
                                  //           ),
                                  //         );
                                  //       }
                                  //     }),
                                  //   ),
                                  // )
                                  //     : Container(),

                                  // Positioned(
                                  //   bottom: 0,
                                  //   left: 0,
                                  //   right: 0,
                                  //   child: selectTags(context),
                                  // )

                                  Consumer<ChatScreenNotifier>(
                                      builder: (context, data, child) {
                                    return data.ShouldShowTags &&
                                            data.text != ""
                                        ? Positioned(
                                            bottom: 0,
                                            child: FutureBuilder(
                                              future: addTagProperties(),
                                              builder: ((context, snapshot) {
                                                if (ConnectionState.done ==
                                                    snapshot.connectionState) {
                                                  return buildTags(
                                                    context,
                                                    height,
                                                    width,
                                                  );
                                                } else {
                                                  return Container(
                                                    height: height * 0.25,
                                                    width: width * 0.8,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(20),
                                                        topRight:
                                                            Radius.circular(20),
                                                      ),
                                                      border: Border.all(
                                                        color: Colors.grey,
                                                        width: 0.1,
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        child: Lottie.asset(
                                                            'assets/load-shimmer.json',
                                                            fit: BoxFit.fill),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }),
                                            ),
                                          )
                                        : Container();
                                  })
                                ],
                              );
                            } else {
                              return Container();
                            }
                          }
                        },
                      ),
                    ),
                    //Message Text Field container
                    // Container(
                    //   margin: EdgeInsets.fromLTRB(0, 7, 0, 0),
                    //   height: size.height *.098,
                    //   width: size.width * 1.2,
                    //   alignment: Alignment.bottomCenter,
                    // child:
                    Consumer<ChatScreenNotifier>(
                      builder: (context, data, child) {
                        return Container(
                          alignment: Alignment.bottomCenter,
                          // height: // size.height* .1,
                          width: size.width / 1.1,
                          child: Row(children: [
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 8, 0, 13),
                              // height: height *.3,
                              width: size.width / 1.33,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxHeight: 120),
                                child: TextField(
                                  style: TextStyle(fontSize: 16),
                                  // style: TextStyle(
                                  //   color: _message.text.startsWith('@')
                                  //       // &&
                                  //       //         _message.text.endsWith('other')
                                  //       ? Colors.green
                                  //       : Colors.black,
                                  // ),
                                  onChanged: (text) {
                                    providerChatScreenNotifier
                                        .sendTextMessage(text);
                                    if (text.contains('@') && text.isNotEmpty) {
                                      // shouldShowTags = true;
                                      providerChatScreenNotifier.showTags(true);
                                    } else {
                                      // shouldShowTags = true;
                                      providerChatScreenNotifier
                                          .showTags(false);
                                    }
                                    // setState(() {
                                    //   if (text.contains('@')) {
                                    //     shouldShowTags = true;
                                    //   } else {
                                    //     shouldShowTags = false;
                                    //   }
                                    //   if (text.isNotEmpty) {
                                    //     textFocusCheck = true;
                                    //   } else {
                                    //     textFocusCheck = false;
                                    //   }
                                    // });
                                  },
                                  // keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  controller: _message,
                                  autocorrect: true,
                                  cursorColor: Colors.purple,
                                  textInputAction: TextInputAction.newline,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 4, 0, 5),
                                    // all(4),
                                    suffixIcon: IconButton(
                                      onPressed: () =>
                                          getImage(context, 'image'),
                                      icon: const Icon(
                                        Icons.attach_file,
                                        color: Color(0xFF7860DC),
                                      ),
                                    ),
                                    fillColor:
                                        const Color.fromARGB(255, 119, 5, 181),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color:
                                              Color.fromARGB(255, 35, 6, 194),
                                          width: 2.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    hintText: "Ask Your Doubt...",
                                    hintStyle: TextStyle(
                                        fontSize: 15.0,
                                        color:
                                            Color.fromARGB(255, 183, 183, 183)),
                                    border: OutlineInputBorder(
                                      gapPadding: 0.0,
                                      borderRadius: BorderRadius.circular(
                                        (5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 8, 0, 13),
                              child: Ink(
                                decoration: ShapeDecoration(
                                  color: Color(0xFF7860DC),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: IconButton(
                                  focusColor: Colors.blue,
                                  splashRadius: 30,
                                  splashColor: Colors.blueGrey,
                                  onPressed: () {
                                    providerChatScreenNotifier
                                        .sendTextMessage("");
                                    _message.text != ""
                                        ? onSendMessage()
                                        : onSendAudioMessage();
                                    //To bring latest msg on top
                                    // await _firestore
                                    //     .collection('groups')
                                    //     .doc(widget.groupData!.id)
                                    //     .update({'time': DateTime.now()});
                                  },
                                  icon: Consumer<ChatScreenNotifier>(
                                    builder: (context, child, value) {
                                      print(child.text);
                                      return child.text == ""
                                          ? const Icon(Icons.mic)
                                          : const Icon(Icons.send);
                                    },
                                  ),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ]),
                        );
                      },
                    )
                    // ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget messages(Size size, Map<String, dynamic> map, BuildContext context,
      Directory? appStorage, String currentTag) {
    // var list = [];
    // print("Detector---------------------${map["message"][0]}");
    // var link = "";
    // for(int i=0;i<map["message"].length-4;i++)
    // {
    //   if(map["message"][i]=='h' && map["message"][i+1]=='t' && map["message"][i+2]=='t' && map["message"][i+3]=='p')
    //   {
    //     link!=""?list.add(link):null;
    //     link = "";
    //     for(int j=i;map["message"][j]!=" " && j<map["message"].length-1;j++) {
    //       link += map["message"][j];
    //     }
    //     list.add(link);
    //     link = "";
    //     continue;
    //   }
    //   link+=map["message"][i];
    // }
    // print("Link----$list");

    //help us to show the text and the image in perfect alignment
    return map['type'] == "text" //checks if our msg is text or image
        ? MessageTile(size, map, widget.userData["name"], currentTag)
        : map["type"] == "image"
            ? ImageMsgTile(
                size: size,
                map: map,
                displayName: widget.userData["name"],
                appStorage: appStorage)
            : map["type"] == "audio"
                ? Container(
                    child: AudioMsgTile(
                      size: size,
                      map: map,
                      displayName: widget.userData["name"],
                      appStorage: appStorage,
                    ),
                  )
                : FileMsgTile(
                    size: size,
                    map: map,
                    displayName: widget.userData["name"],
                    appStorage: appStorage,
                  );
  }
}
