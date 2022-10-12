import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
                    openFile(url: widget.map!["link"], fileName: widget.map!["link"], );
                  },
                  icon: Icon(Icons.download_for_offline_outlined,
                      color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Future<File?> downloadFile(String url, String name, file) async {
    try {
      final response = await Dio().get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          receiveTimeout: 0,
        ),
      );

      final raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();

      return file;
    } catch (e) {
      return null;
    }
  }

  Future openFile({required String url, String? fileName}) async {
    if (await Permission.storage.request().isGranted) {
      final appStorage = await getExternalStorageDirectory();
      final file = File("${appStorage!.path}/$fileName");

      if (!file.existsSync()) {
        Fluttertoast.showToast(msg: "Downloading...");
        final downloadedFile = await downloadFile(url, fileName!, file);
        if (downloadedFile != null) {
          OpenFilex.open(downloadedFile.path);
          print('this is downloaded image: $downloadedFile');
        }
      } else {
        OpenFilex.open(file.path);
        print('this is downloaded name: $fileName');
        print('this is downloaded name: ${file.path}');
      }
    }
  }
}
