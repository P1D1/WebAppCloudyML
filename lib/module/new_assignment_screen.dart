import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Assignment_Screen extends StatefulWidget {
  const Assignment_Screen({Key? key}) : super(key: key);

  @override
  State<Assignment_Screen> createState() => _Assignment_ScreenState();
}

class _Assignment_ScreenState extends State<Assignment_Screen> {
  String urlIPYNB =
      "https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/Assignments%2FPython_Withoutcode.ipynb?alt=media&token=9172c5b5-9350-4e66-bb4a-077181d04607";
  String outputPDF =
      "https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/OuputPDF%2FCML115.pdf?alt=media&token=683d514c-336f-4b16-8352-0467152bed6d";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Assignment Instructions',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey,
                                width: 0.2,
                                style: BorderStyle.solid)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Please download the assignment, watch videos as instructed and answer all questions ",
                                  textAlign: TextAlign.left,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "accordingly. Open colab by clicking here : ",
                                      textAlign: TextAlign.left,
                                    ),
                                    InkWell(
                                        onTap: () => launch(
                                            'https://colab.research.google.com/'),
                                        child: Text(
                                          "https://colab.research.google.com/",
                                          style: TextStyle(
                                              color: Colors.deepPurpleAccent),
                                        )),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Text("Reference PDF for output "),
                                    InkWell(
                                        onTap: () => launch(outputPDF),
                                        child: Text(
                                          'Python_output.pdf',
                                          style: TextStyle(
                                              color: Colors.deepPurpleAccent),
                                        )),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                InkWell(
                                    onTap: () => launch(urlIPYNB),
                                    child: Text(
                                      'Python_Withoutcode.ipynb (650.23 KB)',
                                      style: TextStyle(
                                          color: Colors.deepPurpleAccent),
                                    )),
                              ]),
                        ),
                      ),
                    ),
                    //main grey container
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white12, width: 0.5),
                        color: Colors.black12,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Assignment upload ",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "You can upload maximum 200 MB of file size.",
                                  style: TextStyle(color: Colors.black54, fontSize: 12),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            //button container
                            Container(
                              padding: EdgeInsets.only(left: 20),
                              width: MediaQuery.of(context).size.width / 1.2,
                              color: Colors.black12,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      child: Text("Choose file",
                                          style:
                                              TextStyle(color: Colors.black26)),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "No file chosen",
                                    style: TextStyle(color: Colors.black26),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Notes",
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10,),
                            Container(
                              width: MediaQuery.of(context).size.width / 2,
                              padding: EdgeInsets.all(20.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.white12, width: 0.5),
                                borderRadius: BorderRadius.circular(5.0)
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                                maxLines: 10,
                                minLines: 5,
                                autocorrect: true,
                                scribbleEnabled: false,
                              ),
                            ),
                            SizedBox(height: 10,),
                            ElevatedButton(
                                onPressed: () {},
                                child: Text("Submit"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurpleAccent,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
