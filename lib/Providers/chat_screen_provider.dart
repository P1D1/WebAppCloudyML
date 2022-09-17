import 'package:flutter/foundation.dart';

class ChatScreenNotifier extends ChangeNotifier{
  String text = "";
  String sendTextMessage(str)
  {
    text = str;
    notifyListeners();
    return text;
  }
}
