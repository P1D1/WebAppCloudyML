import 'dart:html';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloudyml_app2/helpers/file_handler.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

import '../api/firebase_api.dart';
import '../models/firebase_file.dart';

class FullScreenImage extends StatefulWidget {
  final Map<String, dynamic>? map;

  FullScreenImage({this.map});

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            CachedNetworkImage(
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
                imageUrl: widget.map!["link"],
                fit: BoxFit.cover),
            Positioned(
                left: 10,
                child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.cancel_outlined,
                      color: Colors.black,
                    ))),
            Positioned(
              right: 10,
              child: IconButton(
                  onPressed: () async {
                    print('download link: ${widget.map!['link']}');
                    await downloadFile(widget.map!['link']);
                    print('executed link: ${widget.map!['link']}');
                    await ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Downloading file')));
                  },
                  icon: Icon(Icons.download_for_offline_outlined,
                      color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> downloadUrl() async {
  //   setState(() {
  //     downloading = true;
  //   });
  //   await _webImageDownloader.downloadImageFromWeb(widget.map!['link'], imageQuality: 0.5);
  //   setState(() {
  //     downloading = false;
  //   });
  //   print('loading snackbar');
  // }

  downloadFile(url) {
    AnchorElement anchorElement = AnchorElement(href: url);
    anchorElement.download = 'Any image';
    anchorElement.click();
  }
}
