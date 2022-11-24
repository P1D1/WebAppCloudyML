import 'package:flutter/material.dart';

final textFormFieldDecoration = InputDecoration(
    contentPadding: EdgeInsets.all(10),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black26, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 1),
    ));

TextEditingController firstNameC = TextEditingController();
TextEditingController lastNameC = TextEditingController();
TextEditingController emailC = TextEditingController();
TextEditingController phoneNumberC = TextEditingController();

final textStyle1 = TextStyle(
  color: Colors.deepOrangeAccent,
  fontSize: 14,
  fontWeight: FontWeight.bold,
);

final textStyle2 = TextStyle(
  color: Colors.black,
  fontSize: 12,
  fontWeight: FontWeight.w700,
);
final decoration = BoxDecoration(
  color: Colors.white,
  border: Border.all(color: Colors.white),
  borderRadius: BorderRadius.circular(5),
);