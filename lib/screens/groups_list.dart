import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/fun.dart';
import 'package:cloudyml_app2/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import '../Providers/UserProvider.dart';
import '../widgets/group_tile.dart';

class GroupsList extends StatefulWidget {
  @override
  State<GroupsList> createState() => _GroupsListState();
  static ValueNotifier<int> messageCount = ValueNotifier(0);
}

class _GroupsListState extends State<GroupsList> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ValueNotifier<bool> _gettingMoreGroupDetails = ValueNotifier(false);
  ValueNotifier<bool> _moreGroupDetailsAvailable = ValueNotifier(true);
  FirebaseAuth _auth = FirebaseAuth.instance;
  dynamic groupData;
  // dynamic userData;
  String? groupId;
  List<int> newchatcount = [];
  bool isLoading = false;
  int? count;
  List? groupsList = [];
  DateTime now = new DateTime.now();
  static const int documentLimit = 50;
  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;

  DocumentSnapshot<Map<String, dynamic>>? _lastDocument1;
  ScrollController _scrollController = ScrollController();
  // ValueNotifier<int> studentCount = ValueNotifier(0);
  Map? userData = {};
  loadUserData() async {
    setState(() {
      isLoading = true;
    });
    await _firestore
        .collection("Users")
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) {
      // print("user data-- ${value.data()}");
      setState(() {
        userData = value.data();
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  // void _getGroupDetails() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   QuerySnapshot<Map<String, dynamic>> querySnapshot =
  //   userData!['role'] == 'student'
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
  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  // void _getMoreGroupDetails() async {
  //   if (_gettingMoreGroupDetails.value) {
  //     return;
  //   }
  //   if (!_moreGroupDetailsAvailable.value) {
  //     return;
  //   }
  //   _gettingMoreGroupDetails.value = true;
  //   QuerySnapshot<Map<String, dynamic>> querySnapshot =
  //   userData!['role'] == 'student'
  //       ? await _firestore
  //       .collection("groups")
  //       .where("student_id", isEqualTo: _auth.currentUser!.uid)
  //       .startAfterDocument(_lastDocument!)
  //       .limit(documentLimit)
  //       .get()
  //       .then((value) => value)
  //       : await _firestore
  //       .collection("groups")
  //       .orderBy('time', descending: true)
  //       .startAfterDocument(_lastDocument!)
  //       .limit(documentLimit)
  //       .get()
  //       .then((value) => value);
  //   final groupDetailsList = querySnapshot.docs
  //       .map((doc) => {
  //     "id": doc.id,
  //     "data": doc.data(),
  //   })
  //       .toList();
  //
  //   if (!(groupsList!.contains(groupDetailsList[0]))) {
  //     groupsList?.addAll(groupDetailsList);
  //     // getchatcount(groupDetailsList);
  //   }
  //   print(groupsList?.length);
  //   if (querySnapshot.docs.length < documentLimit) {
  //     _moreGroupDetailsAvailable.value = false;
  //   }
  //   _gettingMoreGroupDetails.value = false;
  // }

  void getchatcount(List groupDetailsList) async {
    for (var group in groupDetailsList) {
      await _firestore
          .collection("groups")
          .doc(group['id'])
          .collection("chats")
          .where('sendBy', isNotEqualTo: userData!["name"])
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          newchatcount.add(value.docs.length);
        }
      });
    }
  }

  // void onScrollListner() {
  //   double maxScroll = _scrollController.position.maxScrollExtent;
  //   double currentScroll = _scrollController.position.pixels;
  //   double delta = MediaQuery.of(context).size.height;
  //   if (maxScroll - currentScroll <= delta * 0.2) {
  //     _getMoreGroupDetails();
  //   }
  // }

  QuerySnapshot<Map<String,dynamic>>? querySnapshot;
  List<DocumentSnapshot<Map<String, dynamic>>>? list = [];

  ScrollBottomUpdateData()
  async{
    setState(() {
      isLoading = true;
    });

    if(_lastDocument1==null)
    {
      querySnapshot = await FirebaseFirestore.instance.collection("groups")
          .orderBy("time",descending: true).limit(documentLimit).get();
      _lastDocument1 = querySnapshot!.docs[querySnapshot!.docs.length-5];
      print("last");
      try{

        list!.add(_lastDocument1!);
      }
      catch(err)
      {
        print("err"+err.toString());
      }
        print(list!.length);
      print(_lastDocument1.toString()+"Laststring");
      print(_lastDocument1!.id);
      print(_lastDocument1!.data());
    }
    else
    {
      print("Inside");

        querySnapshot = await FirebaseFirestore.instance.collection("groups")
            .orderBy("time",descending: true).startAfterDocument(_lastDocument1!).limit(documentLimit).get().then((value) => value);


      _lastDocument1 = querySnapshot!.docs[querySnapshot!.docs.length-5];
      // _lastDocument1 = querySnapshot!.docs.last;
      // documentLimit +=documentLimit;
      list?.add(_lastDocument1!);
      print(list!.length);
      print(_lastDocument1.toString()+"Not null");
      print(_lastDocument1!.id);
      print(_lastDocument1!.data());
    }
    Future.delayed(Duration(seconds: 1),(){

      setState(() {
        isLoading = false;
        print("DocumentLimit ====$documentLimit");
        // documentLimit +=documentLimit;
      });
    });
  }

  ScrollTopUpdateData()
  async{
    setState(() {
      isLoading = true;
    });
    if(querySnapshot!=null) {
      if (querySnapshot!.docs.length >= documentLimit &&
          (list!.length - 2) >= 0 && list != null) {
        print("True");
        querySnapshot = await FirebaseFirestore.instance.collection("groups")
            .orderBy("time", descending: true).
        startAfterDocument(list![list!.length - 2]).
        limit(documentLimit).get().then((value) => value);
        list!.removeLast();
        _lastDocument1 = querySnapshot!.docs.first;
        print(_lastDocument1.toString() + "Not null");
        print(_lastDocument1!.id);
        print(_lastDocument1!.data());
      }
      else {
        print("false");
        _lastDocument1 = null;
        list = [];
      }
    }
    else {
      print("false");
      _lastDocument1 = null;
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    loadUserData();
    // _getGroupDetails();
    // call();
    Future.delayed(Duration(milliseconds: 1000), () {
      // _getGroupDetails();
      Future.delayed(Duration(milliseconds: 1000), () {
        // getchatcount();
      });
      _scrollController.addListener(() {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.position.pixels;
        double delta = MediaQuery.of(context).size.height;
        if (maxScroll - currentScroll <= delta * 0.2) {
          // _getMoreGroupDetails();
          // setState(() {
          //   print("listening......");
          //   print(userData!["role"]);
          // });
            !isLoading && userData!["role"]=="mentor"?ScrollBottomUpdateData():null;
        }

        if(_scrollController.position.atEdge && userData!["role"]=="mentor")
          {
            final isTop = _scrollController.position.pixels==0;
            if(isTop)
              {
                print("REach start....");
                !isLoading?ScrollTopUpdateData():null;
              }
          }

      });
    });
    super.initState();
  }


  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final userprovider = Provider.of<UserProvider>(context);
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF7860DC),
              // gradient: gradient
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            // height: MediaQuery.of(context).size.height*.1 ,
            padding: const EdgeInsets.only(left: 0),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * .08),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      icon: Icon(
                        Icons.menu,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                    ),
                    Row(
                      children: [
                        Text(
                          'Chat',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      userData!["role"] == "student"
                          ? "Groups For You"
                          : "Groups For Mentors",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * .05),
              ],
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              // : groupsList == null || groupsList!.isEmpty
          //     ? Center(
          //   heightFactor: 15,
          //   child: Text(
          //       userData!["role"] == "student"
          //           ? "No Groups To Show!\n(Buy Course To Get Mentor's Support)!"
          //           : "No Groups To Show!",
          //       style: TextStyle(
          //           fontSize: 18,
          //           fontWeight: FontWeight.w500,
          //           color: Colors.grey)),
          // )
              : Expanded(
            child: ValueListenableBuilder(
              valueListenable: _gettingMoreGroupDetails,
              builder: (context, bool value, child) {
                return Stack(
                  children: [
                    StreamBuilder(
                        stream: userData!["role"]=="mentor"?!isLoading?
                        _lastDocument1!=null?FirebaseFirestore.instance.collection("groups").orderBy("time",descending: true)
                            .startAfterDocument(_lastDocument1!).limit(documentLimit).snapshots():
                        FirebaseFirestore.instance.collection("groups").orderBy("time",descending: true)
                            .limit(documentLimit).snapshots():null:FirebaseFirestore.instance.collection("groups")
                            .where("student_id", isEqualTo: _auth.currentUser!.uid)
                            // .orderBy("time",descending: true)
                            .snapshots(),
                        builder: (context,AsyncSnapshot<QuerySnapshot> snapshotGroupList){
                               print("snapshotData = ${snapshotGroupList.data!.docs[0]["icon"]}");
                          if(snapshotGroupList.hasData)
                            {
                              return
                                ListView.builder(
                                controller: _scrollController,
                                itemCount: snapshotGroupList.data!.docs.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    style: ListTileStyle.drawer,
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChatScreen(
                                            groupData: snapshotGroupList.data!.docs[index],
                                            groupId: snapshotGroupList.data!.docs[index].id,
                                            userData: userData,
                                          ),
                                        ),
                                      );
                                      await _firestore
                                          .collection('groups')
                                          .doc(snapshotGroupList.data!.docs[index].id)
                                          .collection('chats')
                                          .where('sendBy',
                                          isNotEqualTo:
                                          userprovider.userModel!.name)
                                          .get()
                                          .then((value) async {
                                        await _firestore
                                            .collection("groups")
                                            .doc(snapshotGroupList.data!.docs[index].id)
                                            .update({
                                          'groupChatCount.${_auth.currentUser!.uid}':
                                          value.docs.length
                                        });
                                      });

                                      // userprovider.userModel!.role == 'student'
                                      //     ? await _firestore
                                      //         .collection("groups")
                                      //         .doc(groupsList![index]['id'])
                                      //         .update({
                                      //         'studentCount':
                                      //             newchatcount.length ==
                                      //                     {index + 1}
                                      //                 ? newchatcount[index]
                                      //                 : 0
                                      //       })
                                      //     : await _firestore
                                      //         .collection("groups")
                                      //         .doc(groupsList![index]['id'])
                                      //         .update({
                                      //         'mentorsCount.${_auth.currentUser!.uid}':
                                      //             newchatcount.isNotEmpty
                                      //                 ? newchatcount[index]
                                      //                 : 0
                                      //       });

                                    },
                                    leading: CircleAvatar(
                                      radius: 22,
                                      backgroundImage: NetworkImage(
                                          snapshotGroupList.data!.docs[index]["icon"]),
                                    ),
                                    title: Text(
                                      snapshotGroupList.data!.docs[index]["name"],
                                      // overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: SizedBox(
                                      height: 35,
                                      width: 70,
                                      child: StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection("groups")
                                            .doc(snapshotGroupList.data!.docs[index].id)
                                            .snapshots(),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<
                                                DocumentSnapshot<
                                                    Map<String, dynamic>>>
                                            documentSnapshot) {
                                          return StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection("groups")
                                                .doc(snapshotGroupList.data!.docs[index].id)
                                                .collection('chats')
                                                .where('sendBy',
                                                isNotEqualTo: userprovider
                                                    .userModel!.name)
                                                .snapshots(),
                                            builder: (
                                                BuildContext context,
                                                AsyncSnapshot<QuerySnapshot>
                                                snapshot,
                                                ) {
                                              if (snapshot.data != null) {
                                                // ((userprovider.userModel!.role ==
                                                //         'student')
                                                //     ? (documentSnapshot.data!
                                                //                 .data()
                                                //             as Map<String, dynamic>)[
                                                //         'studentCount']
                                                //     : (documentSnapshot.data!
                                                //                     .data()
                                                //                 as Map<String,
                                                //                     dynamic>)[
                                                //             'mentorsCount']
                                                //         [_auth.currentUser!.uid])
                                                if (snapshot.data!.docs.length >
                                                    documentSnapshot.data!
                                                        .data()![
                                                    'groupChatCount'][
                                                    _auth.currentUser!
                                                        .uid]) {
                                                  return StreamBuilder(
                                                      stream: FirebaseFirestore
                                                          .instance
                                                          .collection('groups')
                                                          .doc(snapshotGroupList.data!.docs[index].id)
                                                          .collection('chats')
                                                          .orderBy(
                                                        'time',
                                                        descending: true,
                                                      )
                                                          .snapshots(),
                                                      builder: (context,
                                                          AsyncSnapshot<
                                                              QuerySnapshot<
                                                                  Map<String,
                                                                      dynamic>>>
                                                          snap) {
                                                        return Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .end,
                                                          children: [
                                                            snap.data!.docs
                                                                .first
                                                                .data()[
                                                            'message']
                                                                .toString()
                                                                .contains(
                                                                '@${_auth.currentUser!.displayName}')
                                                                ? Text(
                                                              '@',
                                                              style:
                                                              TextStyle(
                                                                fontSize:
                                                                20,
                                                                color: Colors
                                                                    .green,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                              ),
                                                            )
                                                                : SizedBox(),
                                                            Card(
                                                              color: Colors
                                                                  .green
                                                                  .shade400,
                                                              shape:
                                                              RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                  100,
                                                                ),
                                                              ),
                                                              child: SizedBox(
                                                                height: 35,
                                                                width: 30,
                                                                child: Center(
                                                                  child: Text(
                                                                    '${snapshot.data!.docs.length - documentSnapshot.data!.data()!['groupChatCount'][_auth.currentUser!.uid]}',
                                                                    style:
                                                                    TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      });
                                                } else {
                                                  return SizedBox();
                                                }
                                              } else
                                                return SizedBox();
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        userData!["role"] == "mentor"
                                            ? Text(
                                            "Student: ${snapshotGroupList.data!.docs[index]["student_name"]}")
                                            : SizedBox(),
                                        StreamBuilder(
                                          stream: FirebaseFirestore.instance
                                              .collection('groups')
                                              .doc(snapshotGroupList.data!.docs[index].id)
                                              .collection('chats')
                                              .orderBy(
                                            'time',
                                            descending: true,
                                          )
                                              .snapshots(),
                                          builder: (context,
                                              AsyncSnapshot<
                                                  QuerySnapshot<
                                                      Map<String, dynamic>>>
                                              snapshot) {
                                            if (snapshot.data != null) {
                                              return Text(
                                                snapshot.data?.docs.first
                                                    .data()['message'],
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              );
                                            } else {
                                              return SizedBox();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }
                          else if(snapshotGroupList.connectionState==ConnectionState.active)
                            {
                              return Center(
                                heightFactor: 15,
                                child: Text(
                                    userData!["role"] == "student"
                                        ? "No Groups To Show!\n(Buy Course To Get Mentor's Support)!"
                                        : "No Groups To Show!",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey)),
                              );
                            }
                          else if(snapshotGroupList.hasError)
                            {
                              return Text("Error");
                            }
                          else
                          {
                            return Center(
                                  heightFactor: 15,
                                  child: Text(
                                      userData!["role"] == "student"
                                          ? "No Groups To Show!\n(Buy Course To Get Mentor's Support)!"
                                          : "No Groups To Show!",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey)),
                                );
                          }

                    }),

                    value
                        ? Container(
                      color: Color.fromARGB(113, 221, 210, 251),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF7860DC),
                          backgroundColor: Color(0xFFC0AAF5),
                        ),
                      ),
                    )
                        : SizedBox()
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}