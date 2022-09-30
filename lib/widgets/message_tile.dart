import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hexcolor/hexcolor.dart';

String lastCurrentTag = '';

Widget MessageTile(size, map, displayName, currentTag) {

  var list = [];
  var link = "";
  print(map["message"]);
  if(map["message"].contains("https"))
    {
      for(int i=0;i<map["message"].length;i++)
      {
        if(map["message"][i]!=" ")
        {
          link+=map["message"][i];
          if(i==map["message"].length-1)
          {
            list.add(link);
          }
        }
        else{
          list.add(link);
          link = "";
        }
      }
    }
  // String taggedNameText = '';
  // String untaggedText = '';
  // if (currentTag.toString().contains('@')) {
  //   taggedNameText = '$currentTag ';
  //   if (map['message'].toString().contains('@')) {
  //     untaggedText = map['message'].toString().replaceFirst(RegExp(r'@'),'');
  //   } else {
  //     untaggedText = map['message'].toString().replaceAll('$currentTag', '');
  //   }
  // } else {
  //   untaggedText = map['message'].toString();
  // }
  // lastCurrentTag = currentTag;
  return Container(
    width: size.width,
    alignment: map!['sendBy'] == displayName
        ? Alignment.centerRight
        : Alignment.centerLeft,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      decoration: BoxDecoration(
        // borderRadius: BorderRadius.only(
        //   topLeft: map!["sendBy"] == displayName
        //       ? const Radius.circular(20)
        //       : const Radius.circular(0),
        //   bottomRight: const Radius.circular(20),
        //   bottomLeft: const Radius.circular(20),
        //   topRight: map!["sendBy"] == displayName
        //       ? const Radius.circular(0)
        //       : const Radius.circular(20),
        // ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.7),
        //     spreadRadius: 5,
        //     blurRadius: 5,
        //     offset: Offset(10, 10), // changes position of shadow
        //   ),
        // ],
        borderRadius: BorderRadius.circular(25),
        // gradient: const RadialGradient(
        //     center: Alignment.topRight,
        //     // near the top right
        //     radius: 6,
        //     colors: [
        //       Colors.purple,
        //       Colors.blue,
        //     ]),
        color: map!["sendBy"] == displayName
            ? HexColor("#6da2f7")
            : HexColor("#b3afb0"),
      ),
      constraints: BoxConstraints(
        maxWidth: size.width * 0.7,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              (map['sendBy']),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          SizedBox(
            height: 4,
          ),
          Align(
            alignment: Alignment.topLeft,
            child:
            SelectableText.rich(
               map["message"].contains("https")?
              TextSpan(children: List.generate(list.length, (index) {
                return TextSpan(
                  text: list[index]+" ",
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async{
                      if(list[index].contains("https"))
                        {
                          if (await canLaunch(list[index])) {
                            await launch(list[index]);
                          } else {
                            throw 'Could not launch ${list[index]}';
                          }
                        }
                    },
                  style: TextStyle(
                    decoration: list[index].contains("https")?TextDecoration.underline:null,
                    color: list[index].contains("https")?HexColor("#0509f7"):Colors.white,
                    // fontWeight: FontWeight.bold,
                    fontSize: 18,

                  ),
                );
              })
              ):TextSpan(
                children: [
              TextSpan(
              text: map["message"],
                  style: TextStyle(
                    // decoration: list[index].contains("https")?TextDecoration.underline:null,
                    color: Colors.white,
                    // fontWeight: FontWeight.bold,
                    fontSize: 18,
                  )),
                ]
              )

            ),

            // SelectableText(
            //   map['message'],
            //   textWidthBasis: TextWidthBasis.parent,
            //   style: GoogleFonts.archivo(
            //     color: Colors.white,
            //     fontSize: 15,
            //   ),
            // ),
          ),
          SizedBox(
            height: 2,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              DateFormat('hh:mm a')
                  .format(map!["time"] != null
                  ? map!["time"].toDate()
                  : DateTime.now())
                  .toLowerCase(),
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    ),
  );
}