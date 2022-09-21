import 'package:auto_orientation/auto_orientation.dart';
import 'package:cloudyml_app2/globals.dart';
import 'package:cloudyml_app2/widgets/settings_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:video_player/video_player.dart';

class VideoPlayerCustom extends StatefulWidget {
  final String url;
  VideoPlayerCustom({Key? key, required this.url}) : super(key: key);

  @override
  _VideoPlayerCustomState createState() => _VideoPlayerCustomState();
}

class _VideoPlayerCustomState extends State<VideoPlayerCustom> {
  VideoPlayerController? _controller;
  bool enablePauseScreen = false;
  bool _isBuffering = false;
  Future<void>? _video;
  Duration? _position;
  Duration? _duration;
  bool _disposed = false;
  bool _isPlaying = false;
  var _delayToInvokeonControlUpdate = 0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url);
    _video = _controller!.initialize().then((_) {
      _controller?.addListener(_onVideoControllerUpdate);
      _controller!.play();
    });
  }

  void _onVideoControllerUpdate() {
    if (_disposed) {
      return;
    }
    // _delayToInvokeonControlUpdate = 0;
    final now = DateTime.now().microsecondsSinceEpoch;
    if (_delayToInvokeonControlUpdate > now) {
      return;
    }
    _delayToInvokeonControlUpdate = now + 500;
    final controller = _controller;
    if (controller == null) {
      debugPrint("The video controller is null");
      return;
    }
    if (!controller.value.isInitialized) {
      debugPrint("The video controller cannot be initialized");
      return;
    }
    if (_duration == null) {
      _duration = _controller!.value.duration;
    }
    var duration = _duration;
    if (duration == null) return;
    setState(() {});

    var position = _controller?.value.position;
    setState(() {
      _position = position;
    });
    final playing = controller.value.isPlaying;
    _isPlaying = playing;
  }

  String convertToTwoDigits(int value) {
    return value < 10 ? "0$value" : "$value";
  }

  Widget timeRemainingString() {
    var timeRemaining = _duration?.toString().substring(2, 7);
    final duration = _duration?.inSeconds ?? 0;
    final currentPosition = _position?.inSeconds ?? 0;
    final timeRemained = max(0, duration - currentPosition);
    final mins = convertToTwoDigits(timeRemained ~/ 60);
    final seconds = convertToTwoDigits(timeRemained % 60);
    timeRemaining = '$mins:$seconds';
    return Column(
      children: [
        Text(
          timeRemaining,
          style: TextStyle(
              color: Colors.white,
              // fontSize: 12,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget timeElapsedString() {
    var timeElapsedString = "00.00";
    // final duration = _duration?.inSeconds ?? 0;
    final currentPosition = _position?.inSeconds ?? 0;
    final mins = convertToTwoDigits(currentPosition ~/ 60);
    final seconds = convertToTwoDigits(currentPosition % 60);
    timeElapsedString = '$mins:$seconds';
    return Column(
      children: [
        Text(
          timeElapsedString,
          style: TextStyle(
              color: Colors.white,
              // fontSize: 12,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  void dispose() {
    AutoOrientation.portraitAutoMode();
    _disposed = true;
    _controller?.removeListener(_onVideoControllerUpdate);
    _controller!.dispose();
  }

  Widget _buildControls(
    BuildContext context,
    bool isPortrait,
    double horizontalScale,
    double verticalScale,
  ) {
    return Container(
      color: Color.fromARGB(114, 0, 0, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ListTile(
            leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              ),
            ),
            trailing: InkWell(
              onTap: () {
                showSettingsBottomsheet(
                  context,
                  horizontalScale,
                  verticalScale,
                  _controller!,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              replay10(
                videoController: _controller,
              ),
              !_isBuffering
                  ? InkWell(
                      onTap: () {
                        if (_isPlaying) {
                          setState(() {
                            _controller!.pause();
                          });
                        } else {
                          setState(() {
                            enablePauseScreen = !enablePauseScreen;
                            _controller!.play();
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
                videoController: _controller,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  // height: 10,
                  child: VideoProgressIndicator(
                    _controller!,
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
                          '/${_controller!.value.duration.toString().substring(2, 7)}',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    var verticalScale = screenHeight / mockUpHeight;
    var horizontalScale = screenWidth / mockUpWidth;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: FutureBuilder(
          future: _video,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return OrientationBuilder(
                builder: (BuildContext context, Orientation orientation) {
                  final isPortrait = orientation == Orientation.portrait;
                  return Stack(
                    children: [
                      Positioned(
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: VideoPlayer(_controller!),
                          ),
                        ),
                      ),
                      Positioned(
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: _buildControls(
                              context,
                              isPortrait,
                              horizontalScale,
                              verticalScale,
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                },
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
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     if (_controller!.value.isPlaying) {
        //       setState(() {
        //         _controller!.pause();
        //       });
        //     } else {
        //       setState(() {
        //         _controller!.play();
        //       });
        //     }
        //   },
        //   child:
        //       Icon(_controller!.value.isPlaying ? Icons.pause : Icons.play_arrow),
        // ),
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