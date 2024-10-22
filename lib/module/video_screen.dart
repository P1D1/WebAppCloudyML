import 'dart:io';
import 'dart:math';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:cloudyml_app2/models/video_details.dart';
import 'package:cloudyml_app2/offline/db.dart';
import 'package:cloudyml_app2/globals.dart';
import 'package:cloudyml_app2/models/offline_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/widgets/assignment_bottomsheet.dart';
import 'package:cloudyml_app2/widgets/settings_bottomsheet.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:html' as html;
import '../models/course_details.dart';
import 'new_assignment_screen.dart';

class VideoScreen extends StatefulWidget {
  final List<dynamic>? courses;
  final int? sr;
  final bool? isDemo;
  final String? courseName;
  static ValueNotifier<double> currentSpeed = ValueNotifier(1.0);

  const VideoScreen(
      {required this.isDemo, this.sr, this.courseName, this.courses});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController? _videoController;
  bool? downloading = false;
  bool downloaded = false;
  Map<String, dynamic>? data;
  String? videoUrl;
  Future<void>? playVideo;
  bool showAssignment = false;
  int? serialNo;
  String? assignMentVideoUrl;
  bool _disposed = false;
  bool _isPlaying = false;
  bool loading = false;
  bool enablePauseScreen = false;
  bool _isBuffering = false;
  Duration? _duration;
  Duration? _position;
  bool switchTOAssignment = false;
  bool stopdownloading = true;
  bool showAssignSol = false;

  var _delayToInvokeonControlUpdate = 0;
  var _progress = 0.0;
  List<VideoDetails> _listOfVideoDetails = [];

  ValueNotifier<int> _currentVideoIndex = ValueNotifier(0);
  ValueNotifier<int> _currentVideoIndex2 = ValueNotifier(0);
  ValueNotifier<double> _downloadProgress = ValueNotifier(0);

  void getData() async {
    await setModuleId();
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('Modules')
        .doc(moduleId)
        .collection('Topics')
        .orderBy('sr')
        .get()
        .then((value) {
      for (var video in value.docs) {
        _listOfVideoDetails.add(
          VideoDetails(
            videoId: video.data()['id'] ?? '',
            type: video.data()['type'] ?? '',
            canSaveOffline: video.data()['Offline'] ?? true,
            serialNo: video.data()['sr'].toString(),
            videoTitle: video.data()['name'] ?? '',
            videoUrl: video.data()['url'] ?? '',
          ),
        );
      }
    });
  }

  Future<void> setModuleId() async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('Modules')
        .where('firstType', isEqualTo: 'video')
        .get()
        .then((value) {
      moduleId = value.docs[0].id;
    });
  }

  String convertToTwoDigits(int value) {
    return value < 10 ? "0$value" : "$value";
  }

  // Widget timeRemainingString() {
  //   final totalDuration =
  //       _videoController!.value.duration.toString().substring(2, 7);
  //   final duration = _duration?.inSeconds ?? 0;
  //   final currentPosition = _position?.inSeconds ?? 0;
  //   final timeRemained = max(0, duration - currentPosition);
  //   final mins = convertToTwoDigits(timeRemained ~/ 60);
  //   final seconds = convertToTwoDigits(timeRemained % 60);
  //   // timeRemaining = '$mins:$seconds';
  //   return Text(
  //     totalDuration,
  //     style: TextStyle(
  //       color: Colors.white,
  //       fontWeight: FontWeight.bold,
  //     ),
  //   );
  // }

  Widget timeElapsedString() {
    var timeElapsedString = "00.00";
    final currentPosition = _position?.inSeconds ?? 0;
    final mins = convertToTwoDigits(currentPosition ~/ 60);
    final seconds = convertToTwoDigits(currentPosition % 60);
    timeElapsedString = '$mins:$seconds';
    return Text(
      timeElapsedString,
      style: TextStyle(
          color: Colors.white,
          // fontSize: 12,
          fontWeight: FontWeight.bold),
    );
  }

  void _onVideoControllerUpdate() {
    if (_disposed) {
      return;
    }
    final now = DateTime.now().microsecondsSinceEpoch;
    if (_delayToInvokeonControlUpdate > now) {
      return;
    }
    _delayToInvokeonControlUpdate = now + 500;
    final controller = _videoController;
    if (controller == null) {
      debugPrint("The video controller is null");
      return;
    }
    if (!controller.value.isInitialized) {
      debugPrint("The video controller cannot be initialized");
      return;
    }
    if (_duration == null) {
      _duration = _videoController!.value.duration;
    }
    if (!(_videoController!.value.duration >
            _videoController!.value.position) &&
        !_videoController!.value.isPlaying) {
      VideoScreen.currentSpeed.value = 1.0;
      _currentVideoIndex.value++;
      initializeVidController(
        _listOfVideoDetails[_currentVideoIndex.value].videoUrl,
      );
    }
    var duration = _duration;
    if (duration == null) return;
    setState(() {});

    var position = _videoController?.value.position;
    setState(() {
      _position = position;
    });
    final buffering = controller.value.isBuffering;
    setState(() {
      _isBuffering = buffering;
    });
    final playing = controller.value.isPlaying;
    if (playing) {
      if (_disposed) return;
      setState(() {
        _progress = position!.inMilliseconds.ceilToDouble() /
            duration.inMilliseconds.ceilToDouble();
      });
    }
    _isPlaying = playing;
  }

  void initializeVidController(String url) async {
    try {
      final oldVideoController = _videoController;
      if (oldVideoController != null) {
        oldVideoController.removeListener(_onVideoControllerUpdate);
        oldVideoController.pause();
        oldVideoController.dispose();
      }
      final _localVideoController = await VideoPlayerController.network(url);
      setState(() {
        _videoController = _localVideoController;
      });
      playVideo = _localVideoController.initialize().then((value) {
        setState(() {
          _localVideoController.addListener(_onVideoControllerUpdate);
          _localVideoController.play();
          _duration = _localVideoController.value.duration;
        });
      });
    } catch (e) {
      showToast(e.toString());
    }
  }

  void getPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  var courseData;

  String courseName = '';

  Map<String, List> datamap = {};

  List<VideoDetails> _videodetails = [];
  Future<void> getCourseData() async {
    setState(() {
      loading = true;
    });
    var val;
    // CourseDetails? dfs;
    // final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
    // _fireStore.doc
    print(
        "LLLLLLL ${FirebaseAuth.instance.currentUser!.uid} ${courseId}");

    var data = await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .get()
        .then((value) {
      print(value.data());

      val = value.data();

      var curriculumdata = val["curriculum"];
      courseName = val['name'];

      curriculumdata.remove("sectionsName");
      // print(curriculumdata);
      curriculumdata.entries.forEach((entry) async {
        // print('${entry.key}:${entry.value}');
        // print("\n");
        // print("\n");
        // print("\n");
        // print("\n");
        try {
          for (var i in entry.value) {
            // print(i);

            await FirebaseFirestore.instance
                .collection('courses')
                .doc(courseId)
                .collection('Modules')
                .doc(moduleId)
                .collection('Topics')
                .where("name", isEqualTo: "${i.toString().trim()}")
                .get()
                .then(
                  (value) async {
                // print(value.docs);
                for (var video in value.docs) {
                  _videodetails.add(
                    await VideoDetails(
                      videoId: video.data()['id'] ?? '',
                      type: video.data()['type'] ?? '',
                      canSaveOffline: video.data()['Offline'] ?? true,
                      serialNo: video.data()['sr'].toString(),
                      videoTitle: video.data()['name'] ?? '',
                      videoUrl: video.data()['url'] ?? '',
                    ),
                  );
                  // print(video.data()['id']);
                  // print(video.data()['type']);
                  // print(video.data()['Offline']);
                  // print(video.data()['sr'].toString());
                  // print(video.data()['name']);
                  // print(video.data()['url']);
                }
                // var planets = <String, List>{entry.key: _videodetails};

                // datamap.entries.forEach((entry) {
                //   print(
                //       'Kdddddddddddddddddddddddddddddey = ${entry.key} : Vaddddddddddddddddddddddddddddddddlue = ${entry.value}');
                // });
              },
            );
          }
        } catch (e) {
          print(e.toString());
        }

        try {
          print(
              'Kdddddddddddddddddddddddddddddey = ${entry.key} : Vaddddddddddddddddddddddddddddddddlue = ${entry.value}');
          print(entry.key);
          datamap[entry.key] = _videodetails.toList();

          _videodetails.clear();
        } catch (e) {
          print(1);
          print(e);
        }

        //     datamap.entries.forEach((entry) {
        //   print(
        //       'Kdddddddddddddddddddddddddddddey = ${entry.key} : Vaddddddddddddddddddddddddddddddddlue = ${entry.value}');
        // });
      });
      try {
        courseData = datamap;
        courseData = courseData;
        print("yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy ");
        print(curriculumdata.length);
        print(courseData);
        if (courseData == datamap) {
          setState(() {
            loading = false;
            courseData;
          });
        }

        print("LLLLLLLLLLLLLLLLLLyyyyyyyyyyyyyy ");
      } catch (e) {
        print('2');
        if (courseData == datamap) {
          setState(() {
            loading = false;
            courseData;
          });
        }
        print(e);
      }
    });
    if (courseData == datamap) {
      setState(() {
        loading = false;
        courseData;
      });
    }
    // for (var i = 0; i < datamap.length; i++) {
    //   var value = datamap.entries.elementAt(i).value;
    //   for (var i in value) {
    //     resultValue.add(OptionItem(id: 'null', title: i.videoTitle));
    //   }
    //   print(resultValue);
    // }

    print("LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL ");
  }

  Future download({
    Dio? dio,
    String? url,
    String? savePath,
    String? fileName,
    String? courseName,
    String? topicName,
  }) async {
    getPermission();
    var directory = await getApplicationDocumentsDirectory();
    try {
      setState(() {
        downloading = true;
      });
      Response response = await dio!.get(
        url!,
        onReceiveProgress: (rec, total) {
          _downloadProgress.value = rec / total;
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      print(response.headers);
      File file = File(savePath!);
      var raf = file.openSync(mode: FileMode.write);
      print('savePath--$savePath');

      raf.writeFromSync(response.data);
      await raf.close();
      DatabaseHelper _dbhelper = DatabaseHelper();
      OfflineModel video = OfflineModel(
          topic: topicName,
          path: '${directory.path}/${fileName!.replaceAll(' ', '')}.mp4');
      _dbhelper.insertTask(video);

      setState(() {
        downloading = false;
        downloaded = true;
      });
    } catch (e) {
      print('e::$e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    AutoOrientation.portraitUpMode();
    _disposed = true;

    _videoController!.dispose();
    _videoController = null;
  }

  @override
  void initState() {
    html.window.document.onContextMenu.listen((evt) => evt.preventDefault());
    VideoScreen.currentSpeed.value = 1.0;

    getData();
    getCourseData();

    Future.delayed(Duration(milliseconds: 500), () {
      initializeVidController(_listOfVideoDetails[0].videoUrl);
    });

    super.initState();
  }

  bool menuClicked = false;

  @override
  Widget build(BuildContext context) {
    List<CourseDetails> course = Provider.of<List<CourseDetails>>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    var verticalScale = screenHeight / mockUpHeight;
    var horizontalScale = screenWidth / mockUpWidth;
    return Scaffold(
        body: Container(
      color: Colors.white,
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          final isPortrait = orientation == Orientation.portrait;
          return Row(
            children: [
              menuClicked ?
              isPortrait
                  ? Container()
                  : SizedBox() :
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(Icons.arrow_back_ios),
                                Text(
                                  'Back to courses',
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          )),
                    ),
                    // Expanded(
                    //   flex: 0,
                    //     child: _buildPartition(
                    //   context,
                    //   horizontalScale,
                    //   verticalScale,
                    // ),),
                    Expanded(
                      child: _buildVideoDetailsListTiles(
                        horizontalScale,
                        verticalScale,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child:
                showAssignment ?
                AssignmentScreen(
                  selectedSection: selectedSection,
                  courseData: courseData,
                  courseName: widget.courseName,

                    ) :
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder(
                      future: playVideo,
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (ConnectionState.done ==
                            snapshot.connectionState) {
                          return Stack(
                            children: [
                              Container(
                                height: menuClicked ? screenHeight : screenHeight/1.2,
                                child: Center(
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child:
                                    VideoPlayer(_videoController!),
                                  ),
                                ),
                              ),
                              InkWell(
                                  onTap: () {
                                    setState(() {
                                      enablePauseScreen = !enablePauseScreen;
                                      print('Container of column clicked');
                                    });
                                  },
                                  child: Container(
                                    height: menuClicked ? screenHeight : screenHeight/1.2,
                                    width: screenWidth,
                                  )),
                              enablePauseScreen
                                  ? Container(
                                height: menuClicked ? screenHeight : screenHeight/1.2,
                                    child: _buildControls(
                                        context,
                                        isPortrait,
                                        horizontalScale,
                                        verticalScale,
                                      ),
                                  )
                                  : SizedBox(),
                              _isBuffering && !enablePauseScreen
                                  ? Center(
                                      heightFactor: 6.2,
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        child: CircularProgressIndicator(
                                          color: Color.fromARGB(
                                            114,
                                            255,
                                            255,
                                            255,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          );
                        } else {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF7860DC),
                            ),
                          );
                        }
                      },
                    ),
                    menuClicked ? Container() : Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Text(
                        _listOfVideoDetails[_currentVideoIndex.value].videoTitle,
                      style: TextStyle(fontSize: 18, fontFamily: 'SemiBold'),),
                    ),
                    isPortrait
                        ? _buildPartition(
                            context,
                            horizontalScale,
                            verticalScale,
                          )
                        : SizedBox(),
                    isPortrait
                        ? Expanded(
                            flex: 2,
                            child: _buildVideoDetailsListTile(
                              horizontalScale,
                              verticalScale,
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ));
  }

  Widget _buildControls(
    BuildContext context,
    bool isPortrait,
    double horizontalScale,
    double verticalScale,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          enablePauseScreen = !enablePauseScreen;
        });
      },
      child: Container(
        color: Color.fromARGB(114, 0, 0, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ListTile(
              leading: isPortrait
                  ? null
                  : IconButton(
                onPressed: () {
                  setState(() {
                    menuClicked = !menuClicked;
                  });
                   },
                icon: Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
              ),
              title: Text(
                _listOfVideoDetails[_currentVideoIndex.value].videoTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              trailing: InkWell(
                onTap: () {
                  showSettingsBottomsheet(
                    context,
                    horizontalScale,
                    verticalScale,
                    _videoController!,
                  );
                  // var directory = await getApplicationDocumentsDirectory();
                  // download(
                  //   dio: Dio(),
                  //   fileName: data!['name'],
                  //   url: data!['url'],
                  //   savePath:
                  //       "${directory.path}/${data!['name'].replaceAll(' ', '')}.mp4",
                  //   topicName: data!['name'],
                  // );
                  // print(directory.path);
                },
                child: Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _currentVideoIndex,
              builder: (context, value, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _currentVideoIndex.value >= 1
                        ? InkWell(
                            onTap: () {
                              VideoScreen.currentSpeed.value = 1.0;
                              _currentVideoIndex.value--;
                              initializeVidController(
                                _listOfVideoDetails[_currentVideoIndex.value]
                                    .videoUrl,
                              );
                            },
                            child: Icon(
                              Icons.skip_previous_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          )
                        : SizedBox(),
                    replay10(
                      videoController: _videoController,
                    ),
                    !_isBuffering
                        ? InkWell(
                            onTap: () {
                              if (_isPlaying) {
                                setState(() {
                                  _videoController!.pause();
                                });
                              } else {
                                setState(() {
                                  enablePauseScreen = !enablePauseScreen;
                                  _videoController!.play();
                                });
                              }
                            },
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 50,
                            ),
                          )
                        : CircularProgressIndicator(
                            color: Color.fromARGB(
                              114,
                              255,
                              255,
                              255,
                            ),
                          ),
                    fastForward10(
                      videoController: _videoController,
                    ),
                    _currentVideoIndex.value < _listOfVideoDetails.length - 1
                        ? InkWell(
                            onTap: () {
                              VideoScreen.currentSpeed.value = 1.0;
                              _currentVideoIndex.value++;
                              initializeVidController(
                                _listOfVideoDetails[_currentVideoIndex.value]
                                    .videoUrl,
                              );
                            },
                            child: Icon(
                              Icons.skip_next_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          )
                        : SizedBox(),
                  ],
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Container(
                    height: 10,
                    child: VideoProgressIndicator(
                      _videoController!,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        backgroundColor: Color.fromARGB(74, 255, 255, 255),
                        bufferedColor: Color(0xFFC0AAF5),
                        playedColor: Color(0xFF7860DC),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          timeElapsedString(),
                          Text(
                            '/${_videoController!.value.duration.toString().substring(2, 7)}',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      fullScreenIcon(
                        isPortrait: isPortrait,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column _buildPartition(
      BuildContext context, double horizontalScale, double verticalScale) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.courseName!,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: "Medium",
              ),
            ),
          ),
        ),
        SizedBox(
          height: 60,
          child: Center(
            child: Row(
              children: [
                SizedBox(width: 20),
                Expanded(child: _buildLecturesTab(context)),
                SizedBox(width: 30),
                Expanded(
                  flex: 1,
                  child: _buildAssignmentTab(
                    context,
                    horizontalScale,
                    verticalScale,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Container _buildLecturesTab(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'Lectures',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            height: 3,
            width: MediaQuery.of(context).size.width * 0.2,
            color: Color(0xFF7860DC),
          )
        ],
      ),
    );
  }

  InkWell _buildAssignmentTab(
      BuildContext context, double horizontalScale, double verticalScale) {
    return InkWell(
      onTap: () {
        setState(() {
          _videoController!.pause();
          showAssignmentBottomSheet(
            context,
            horizontalScale,
            verticalScale,
          );
        });
      },
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Assignments',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              height: 3,
              width: MediaQuery.of(context).size.width * 0.25,
              color: Color(0xFF7860DC),
            )
          ],
        ),
      ),
    );
  }


  int? selectedSection;

  Widget _buildVideoDetailsListTiles(
      double horizontalScale, double verticalScale) {

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.width;

    print('sddddddddddddddddddddddddddddddddddddddddd');
    print(courseData?.length);
    print('sddddddddddddddddddddddddddddddddddddddddd');
    // return Container();
    return InkWell(
      onTap: () {
        print('sddddddddddddddddddddddddddddddddddddddddd');

        print(courseData?.length);

        print("eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
      },
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Container(
          child: loading
              ? Center(
            child: Container(
              height: 40,
              width: 40,
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          )
              : ListView.builder(
              itemCount: courseData?.length,
              itemBuilder: (BuildContext context, int index) {
                // return Container();
                print("this is index : ${index}");
                var count = -1;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Column(
                    children: [
                      Container(
                          margin: const EdgeInsets.all(5.0),
                          padding: const EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xFF7860DC),
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(
                                25.0) //                 <--- border radius here
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton(
                                alignment: Alignment.center,
                                elevation: 8,
                                isExpanded: true,
                                borderRadius: BorderRadius.circular(23),
                                underline: SizedBox(),
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.black,
                                ),
                                hint:
                                Text(courseData.entries.elementAt(index).key),
                                items: courseData.entries
                                    .elementAt(index)
                                    .value
                                    .map<DropdownMenuItem<String>>(
                                        (dynamic value) {
                                      count += 1;
                                      return DropdownMenuItem<String>(
                                        value: value.videoTitle,
                                        child: GestureDetector(
                                          child: Container(
                                            child: Text(value.videoTitle,
                                                style: TextStyle(
                                                    color: Color(0xFF7860DC),
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14),
                                                maxLines: 3,
                                                textAlign: TextAlign.start,),
                                          ),
                                          onTap: () {
                                            print(value.videoTitle);

                                            VideoScreen.currentSpeed.value = 1.0;

                                            initializeVidController(
                                              value.videoUrl,
                                            );
                                            // _currentVideoIndex.value = index;
                                          },
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (val) {
                                  print(val);
                                },
                                // items: [],
                              ),
                            ),
                          )),
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedSection = index;
                            print('$index and section is $selectedSection');
                            showAssignment = true;
                            _videoController!.pause();
                            enablePauseScreen = !enablePauseScreen;
                          });
                        },
                        child: Container(
                          width: screenWidth/3.1,
                          height: screenHeight/20,
                          decoration: BoxDecoration(
                            color: Colors.purpleAccent[200],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                              child: Text('${index+1} Assignment',)),
                        ),
                      ),
                    ],
                  ),
                );

                // return Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Container(
                //     child: Column(
                //       children: <Widget>[
                //         Container(
                //           padding: const EdgeInsets.symmetric(
                //               horizontal: 15, vertical: 17),
                //           decoration: new BoxDecoration(
                //             borderRadius: BorderRadius.circular(20.0),
                //             color: Colors.white,
                //             boxShadow: [
                //               BoxShadow(
                //                   blurRadius: 10,
                //                   color: Colors.black26,
                //                   offset: Offset(0, 2))
                //             ],
                //           ),
                //           child: new Row(
                //             mainAxisSize: MainAxisSize.max,
                //             crossAxisAlignment: CrossAxisAlignment.center,
                //             children: <Widget>[
                //               // Icon(Icons.card_travel, color: Color(0xFF307DF1),),
                //               SizedBox(
                //                 width: 10,
                //               ),
                //               Expanded(
                //                 child: GestureDetector(
                //                   onTap: () {
                //                     this.isShow = !this.isShow;
                //                     _runExpandCheck(context);
                //                     print(
                //                         "1111111111111111111111111111111111111111111");
                //                     setState(() {});
                //                   },
                //                   child: Text(
                //                     datamap.entries.elementAt(index).key,
                //                     style: TextStyle(
                //                         color: Color(0xFF307DF1), fontSize: 16),
                //                   ),
                //                 ),
                //               ),
                //               Align(
                //                 alignment: Alignment(1, 0),
                //                 child: Icon(
                //                   isShow
                //                       ? Icons.arrow_drop_down
                //                       : Icons.arrow_right,
                //                   color: Color(0xFF307DF1),
                //                   size: 15,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //         SizeTransition(
                //             axisAlignment: 1.0,
                //             sizeFactor: animation,
                //             child: Center(
                //               child: Container(
                //                   margin: const EdgeInsets.only(bottom: 10),
                //                   padding: const EdgeInsets.only(bottom: 10),
                //                   decoration: new BoxDecoration(
                //                     borderRadius: BorderRadius.only(
                //                         bottomLeft: Radius.circular(20),
                //                         bottomRight: Radius.circular(20)),
                //                     color: Colors.white,
                //                     boxShadow: [
                //                       BoxShadow(
                //                           blurRadius: 4,
                //                           color: Colors.black26,
                //                           offset: Offset(0, 4))
                //                     ],
                //                   ),
                //                   child: SizedBox(
                //                     width:
                //                         MediaQuery.of(context).size.width * 0.87,
                //                     child: _buildDropListOptions(
                //                         dropListModel.listOptionItems, context),
                //                   )),
                //             )),
                //         Divider(
                //           color: Colors.grey.shade300,
                //           height: 1,
                //         )
                //       ],
                //     ),
                //   ),
                // );
                // getValueData(0);
                // new GestureDetector(
                //   onTap: () async {
                //     // await getValueData(index);
                //     print(index);
                //   },
                //   child: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: Center(
                //         child: SelectDropList(
                //       OptionItem(
                //           id: 'null', title: datamap.entries.elementAt(index).key),
                //       DropListModel(resultValue),
                //       (optionItem) {
                //         optionItemSelected = optionItem;
                //         setState(() {});
                //       },
                //     )),
                //   ),
                // );
              }),

          // child: StreamBuilder(
          //   stream: FirebaseFirestore.instance
          //       .collection('courses')
          //       .doc(courseId)
          //       .collection('Modules')
          //       .doc(moduleId)
          //       .collection('Topics')
          //       .orderBy('sr')
          //       .snapshots(),
          //   builder: (BuildContext context, AsyncSnapshot snapshot) {
          //     if (snapshot.hasData) {
          //       return ListView.builder(
          //           shrinkWrap: true,
          //           itemCount: snapshot.data!.docs.length,
          //           itemBuilder: (context, index) {
          //             Map<String, dynamic> map = snapshot.data!.docs[index].data();
          //             return Card(
          //               elevation: 0,
          //               color: _currentVideoIndex.value == index
          //                   ? Color(0xFFDDD2FB)
          //                   : Colors.white,
          //               child: ListTile(
          //                 onTap: () {
          //                   VideoScreen.currentSpeed.value = 1.0;
          //                   intializeVidController(
          //                     _listOfVideoDetails[index].videoUrl,
          //                   );
          //                   _currentVideoIndex.value = index;
          //                 },
          //                 leading: Padding(
          //                   padding: const EdgeInsets.all(8.0),
          //                   child: Text('${index + 1}'),
          //                 ),
          //                 title: Text(
          //                   map['name'],
          //                   textScaleFactor: min(
          //                     horizontalScale,
          //                     verticalScale,
          //                   ),
          //                   style: TextStyle(
          //                     fontWeight: FontWeight.w500,
          //                     fontSize: 17,
          //                     fontFamily: "Medium",
          //                   ),
          //                 ),
          //                 trailing:
          //                 // InkWell(
          //                 //   onTap: () async {
          //                 //     var directory =
          //                 //         await getApplicationDocumentsDirectory();
          //                 //     _currentVideoIndex.value = index;
          //                 //     if (stopdownloading == true) {
          //                 //       download(
          //                 //           dio: Dio(),
          //                 //           fileName: map['name'],
          //                 //           url: map['url'],
          //                 //           savePath:
          //                 //               "${directory.path}/${map['name'].replaceAll(' ', '')}.mp4",
          //                 //           topicName: map['name'],
          //                 //           courseName: widget.courseName);
          //                 //       setState(() {
          //                 //         stopdownloading = false;
          //                 //       });
          //                 //     }
          //                 //   },
          //                 //   child: SelectDropList(
          //                 //     this.optionItemSelected,
          //                 //     this.dropListModel,
          //                 //     (optionItem) {
          //                 //       optionItemSelected = optionItem;
          //                 //       setState(() {});
          //                 //     },
          //                 //   ),
          //                 //   // child: _currentVideoIndex.value == index
          //                 //   // ?
          //                 //   // ? Stack(
          //                 //   //     children: [
          //                 //   //       Positioned(
          //                 //   //         bottom: 0,
          //                 //   //         left: 0,
          //                 //   //         right: 0,
          //                 //   //         top: 0,
          //                 //   //         child: Icon(
          //                 //   //           Icons.download_for_offline_rounded,
          //                 //   //         ),
          //                 //   //       ),
          //                 //   //       SizedBox(
          //                 //   //         height: 30,
          //                 //   //         width: 30,
          //                 //   //         child: CircularProgressIndicator(
          //                 //   //           value: _downloadProgress.value,
          //                 //   //           color: Color(0xFF7860DC),
          //                 //   //           backgroundColor: Color(0xFFDDD2FB),
          //                 //   //         ),
          //                 //   //       )
          //                 //   //     ],
          //                 //   //   )
          //                 //   // : Icon(
          //                 //   //     Icons.download_for_offline_rounded,
          //                 //   //   ),
          //                 // ),
          //                 SelectDropList(
          //                     this.optionItemSelected,
          //                     this.dropListModel,
          //                     (optionItem) {
          //                       optionItemSelected = optionItem;
          //                       setState(() {});
          //                     },
          //                   ),
          //               ),
          //             );
          //           });
          // } else {
          //   return Padding(
          //     padding: const EdgeInsets.all(20),
          //     child: Lottie.asset('assets/load-shimmer.json',
          //         fit: BoxFit.fill, reverse: true),
          //   );
          // }
          // },
        ),
      ),
    );
  }

  Widget _buildVideoDetailsListTile(
      double horizontalScale, double verticalScale) {
    return Container(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('Modules')
            .doc(moduleId)
            .collection('Topics')
            .orderBy('sr')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: courseData?.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> map = snapshot.data!.docs[index].data();
                  return Card(
                    elevation: 0,
                    color: _currentVideoIndex.value == index
                        ? Color(0xFFDDD2FB)
                        : Colors.white,
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () {
                            VideoScreen.currentSpeed.value = 1.0;
                            initializeVidController(
                              _listOfVideoDetails[index].videoUrl,
                            );
                            _currentVideoIndex.value = index;
                            showAssignment = false;
                            },
                          leading: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('${index + 1}'),
                          ),
                          title: Text(
                            map['name'],
                            textScaleFactor: min(
                              horizontalScale,
                              verticalScale,
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                              fontFamily: "Medium",
                            ),
                          ),
                          // trailing: InkWell(
                          //   onTap: () async {
                          //     var directory =
                          //         await getApplicationDocumentsDirectory();
                          //     _currentVideoIndex.value = index;
                          //     download(
                          //         dio: Dio(),
                          //         fileName: map['name'],
                          //         url: map['url'],
                          //         savePath:
                          //             "${directory.path}/${map['name'].replaceAll(' ', '')}.mp4",
                          //         topicName: map['name'],
                          //         courseName: widget.courseName);
                          //   },
                          //   child: _currentVideoIndex.value == index
                          //       ? Stack(
                          //           children: [
                          //             Positioned(
                          //               bottom: 0,
                          //               left: 0,
                          //               right: 0,
                          //               top: 0,
                          //               child: Icon(
                          //                 Icons.download_for_offline_rounded,
                          //               ),
                          //             ),
                          //             SizedBox(
                          //               height: 30,
                          //               width: 30,
                          //               child: CircularProgressIndicator(
                          //                 value: _downloadProgress.value,
                          //                 color: Color(0xFF7860DC),
                          //                 backgroundColor: Color(0xFFDDD2FB),
                          //               ),
                          //             )
                          //           ],
                          //         )
                          //       : Icon(
                          //           Icons.download_for_offline_rounded,
                          //         ),
                          // ),
                        ),
                        ListTile(
                          onTap: () {
                            _videoController!.pause();
                            enablePauseScreen = !enablePauseScreen;
                          },
                          leading: Icon(Icons.assignment_ind_outlined),
                          title: Text('Assignment 1.${index + 1}',
                            textScaleFactor: min(
                              horizontalScale,
                              verticalScale,
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                              fontFamily: "Medium",
                            ),),
                        )
                      ],
                    ),
                  );
                });
          } else {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Lottie.asset('assets/load-shimmer.json',
                  fit: BoxFit.fill, reverse: true),
            );
          }
        },
      ),
    );
  }
}

class replay10 extends StatelessWidget {
  const replay10({
    Key? key,
    required VideoPlayerController? videoController,
  })  : _videoController = videoController,
        super(key: key);

  final VideoPlayerController? _videoController;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (() async {
        final currentPosition = await _videoController!.position;
        final newPosition = currentPosition! - Duration(seconds: 10);
        _videoController!.seekTo(newPosition);
      }),
      child: Icon(
        Icons.replay_10,
        size: 40,
        color: Colors.white,
      ),
    );
  }
}

class fastForward10 extends StatelessWidget {
  const fastForward10({
    Key? key,
    required VideoPlayerController? videoController,
  })  : _videoController = videoController,
        super(key: key);

  final VideoPlayerController? _videoController;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (() async {
        final currentPosition = await _videoController!.position;
        final newPosition = currentPosition! + Duration(seconds: 10);
        _videoController!.seekTo(newPosition);
      }),
      child: Icon(
        Icons.forward_10,
        size: 40,
        color: Colors.white,
      ),
    );
  }
}

class fullScreenIcon extends StatelessWidget {
  const fullScreenIcon({
    Key? key,
    required this.isPortrait,
  }) : super(key: key);

  final bool isPortrait;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: IconButton(
        onPressed: () {
          if (isPortrait) {
            AutoOrientation.landscapeRightMode();
          } else {
            AutoOrientation.portraitUpMode();
          }
        },
        icon: Icon(
          isPortrait ? Icons.fullscreen_rounded : Icons.fullscreen_exit_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
