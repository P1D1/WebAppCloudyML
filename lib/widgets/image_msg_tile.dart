import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../helpers/file_handler.dart';
import 'dart:io';
import 'package:hexcolor/hexcolor.dart';
import '../models/firebase_file.dart';
import 'Full_Screen_Image.dart';

class ImageMsgTile extends StatefulWidget {
  final size;
  final Map<String, dynamic>? map;
  final String? displayName;
  final Directory? appStorage;
  ImageMsgTile({this.map, this.displayName, this.appStorage, this.size});

  @override
  State<ImageMsgTile> createState() => _ImageMsgTileState();
}

class _ImageMsgTileState extends State<ImageMsgTile> {

  var filePath;

  String? checkImageExists(fileName) {

    final file = File("${widget.appStorage!.path}/$fileName");

    if (!file.existsSync()) {
      final file = File("${widget.appStorage!.path}/$fileName");
      downloadFile(widget.map!["link"], fileName, file);
      return null;
    } else {
      setState(() {
        filePath = file.path;
      });
      return file.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      alignment: widget.map!['sendBy'] == widget.displayName
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: InkWell(
        onTap: () {
          print("Clicked--------");
          openFile(url: widget.map!["link"], fileName: widget.map!["message"]);
        },
        child: Container(
          width: size.width * 0.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: widget.map!["sendBy"] == widget.displayName
                ? HexColor("#6da2f7")
                : HexColor("#b3afb0"),
            // gradient: const RadialGradient(
            //     center: Alignment.topRight,
            //     // near the top right
            //     radius: 6,
            //     colors: [
            //       Colors.purple,
            //       Colors.blue,
            //     ]),
          ),
          alignment: Alignment.center,
          child: widget.map!['link'] != ""
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: Text(
                        widget.map!["sendBy"],
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    FullScreenImage(
                                      map: widget.map,
                                    )));
                        print('Hello!! Welcome to fullscreen');
                      },
                      child: Container(
                        constraints:
                            BoxConstraints(minHeight: size.width * 0.5),
                        child:
                            // checkImageExists(widget.map!["message"]) != null
                            //     ? Image.file(
                            //         File(filePath),
                            //         fit: BoxFit.cover,
                            //       )
                            CachedNetworkImage(
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                          imageUrl: widget.map!["link"],
                          fit: BoxFit.cover,
                          // loadingBuilder: (BuildContext context,
                          //     Widget child,
                          //     ImageChunkEvent? loadingProgress) {
                          //   if (loadingProgress == null) return child;
                          //   return Center(
                          //     child: CircularProgressIndicator(
                          //       color: Colors.white,
                          //       value: loadingProgress.expectedTotalBytes !=
                          //               null
                          //           ? loadingProgress
                          //                   .cumulativeBytesLoaded /
                          //               loadingProgress.expectedTotalBytes!
                          //           : null,
                          //     ),
                          //   );
                          // },
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      alignment: Alignment.bottomRight,
                      child: Text(
                        DateFormat('hh:mm a')
                            .format(widget.map!["time"].toDate())
                            .toLowerCase(),
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      constraints: BoxConstraints(
                        minWidth: size.width * 0.2,
                      ),
                    )
                  ],
                )
              : Container(
                  height: size.width * 0.5,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
        ),
      ),
    );
  }

  String? downloadURL;

  Future getData() async {
    try{
      await downloadURLExample();
      return downloadURL;
    }catch (e){
      debugPrint(e.toString());
    }
  }

  Future downloadURLExample() async {
    FirebaseStorage storageRef = FirebaseStorage.instance;

           await storageRef.ref().child('test_developer').child(filePath).getDownloadURL();
    debugPrint(downloadURL.toString());

  }
}
