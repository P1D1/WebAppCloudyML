import 'package:flutter/foundation.dart';

class ChatScreenNotifier extends ChangeNotifier{
  String text = "";
  bool ShouldShowTags = false;
  String sendTextMessage(str)
  {
    text = str;
    notifyListeners();
    return text;
  }

  bool showTags(bool expression)
  {
    ShouldShowTags = expression;
    notifyListeners();
    return ShouldShowTags;
  }

}
