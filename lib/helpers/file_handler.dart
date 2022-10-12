import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
      }
    } else {
      OpenFilex.open(file.path);
    }
  }
}
