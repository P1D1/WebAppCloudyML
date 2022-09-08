import 'dart:math';
import 'package:cloudyml_app2/Providers/AppProvider.dart';
import 'package:cloudyml_app2/globals.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/Providers/UserProvider.dart';
import 'package:cloudyml_app2/widgets/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class phoneVerify extends StatefulWidget {
  final String number;

  const phoneVerify({Key? key, required this.number}) : super(key: key);


  @override
  State<phoneVerify> createState() => _phoneVerifyState();
}

class _phoneVerifyState extends State<phoneVerify> {
  final _phonekey = GlobalKey<FormState>();
  final _otpkey = GlobalKey<FormState>();
  String? countryCode = '+91';
  late final String? verifyid;
  bool _isloading = false;
  bool _verifyloading = false;
  String? _editmobile;
  void initState(){
    _editmobile=widget.number;
  }
  FirebaseFirestore _firestore =FirebaseFirestore.instance;
  TextEditingController otpedit = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userprovider=Provider.of<UserProvider>(context);
    final appprovider=Provider.of<AppProvider>(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    var verticalScale = height / mockUpHeight;
    var horizontalScale = width / mockUpWidth;
    return Container(
      margin: EdgeInsets.all(min(horizontalScale, verticalScale) * 24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(min(horizontalScale, verticalScale) * 25)),
      child: ListView(
        padding: EdgeInsets.fromLTRB(horizontalScale * 25, verticalScale * 23,
            horizontalScale * 24, verticalScale * 33),
        shrinkWrap: true,
        children: [
          Center(
              child: Text(
                "Enter Phone Number",
                textScaleFactor: min(horizontalScale, verticalScale),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )),
          SizedBox(
            height: verticalScale * 16,
          ),
          Form(
            key: _phonekey,
            child: Row(
              children: [
                Container(
                  width: horizontalScale * 64,
                  child: TextFormField(
                    initialValue: countryCode,
                    onChanged: (v) {
                      setState(() {
                        countryCode = v;
                      });
                    },
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.deny(' ')],
                    decoration: InputDecoration(
                        hintText: 'Code',
                        labelText: 'Code',
                        floatingLabelStyle: TextStyle(
                            fontSize: 18*min(horizontalScale, verticalScale),
                            fontWeight: FontWeight.w500,
                            color: HexColor('7B62DF')),
                        labelStyle: TextStyle(
                          fontSize: 18*min(horizontalScale, verticalScale),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: HexColor('7B62DF'), width: 2)),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: HexColor('7B62DF'), width: 2),
                        ),
                        errorMaxLines: 2),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter Code';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  width: horizontalScale * 20,
                ),
                Flexible(
                  child: TextFormField(
                    //controller: mobile,
                    initialValue: _editmobile,
                    decoration: InputDecoration(
                        hintText: 'Enter Your Number',
                        labelText: 'Phone Number',
                        counterText: '',
                        floatingLabelStyle: TextStyle(
                            fontSize: 18*min(horizontalScale, verticalScale),
                            fontWeight: FontWeight.w500,
                            color: HexColor('7B62DF')),
                        labelStyle: TextStyle(

                          fontSize:18*min(horizontalScale, verticalScale),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: HexColor('7B62DF'), width: 2)),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: HexColor('7B62DF'), width: 2),
                        ),
                        suffixIcon: Icon(
                          Icons.phone,
                          color: HexColor('6153D3'),
                        )),
                    keyboardType: TextInputType.phone,
                    onSaved: (value){
                      _editmobile=value;
                    },
                    onChanged: (value){
                      setState((){
                        _editmobile=value;
                      });
                    },
                    maxLength: 10,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter Phone No';
                      } else if (!RegExp(
                          r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$')
                          .hasMatch(value)) {
                        return 'Please enter a valid Phone Number';
                      } else if (value.length < 10) {
                        return 'Enter 10 digit Phone number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: verticalScale * 18,
          ),
          Center(
            child: (_isloading)
                ? Loading()
                : InkWell(
              child: Container(
                //height: 20,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Send OTP',
                    textScaleFactor: min(horizontalScale, verticalScale),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20),
                  ),
                ),
                decoration: BoxDecoration(
                  color: HexColor('6153D3'),
                  borderRadius: BorderRadius.circular(
                      min(horizontalScale, verticalScale) * 8),
                  boxShadow: [
                    BoxShadow(
                      color: HexColor('6153D3'),
                      blurRadius: 10.0, // soften the shadow
                      offset: Offset(
                        0, // Move to right 10  horizontally
                        4.0, // Move to bottom 10 Vertically
                      ),
                    )
                  ],
                ),
              ),
              onTap: () async {
                if (_phonekey.currentState!.validate()) {
                  setState(() {
                    _isloading = true;
                  });
                  FirebaseAuth auth = FirebaseAuth.instance;
                  await auth.verifyPhoneNumber(
                    phoneNumber: '$countryCode ${_editmobile}',
                    verificationCompleted:
                        (PhoneAuthCredential credential) async {},
                    codeAutoRetrievalTimeout: (String verificationId) {},
                    codeSent: (String verificationId,
                        int? forceResendingToken) {
                      verifyid = verificationId;
                      setState(() {
                        _isloading = false;
                      });
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            Future.delayed(Duration(seconds: 5), () {
                              Navigator.of(context).pop(true);
                            });
                            return AlertDialog(
                              title: Center(
                                child: Column(
                                  children: [
                                    Lottie.asset('assets/otplottie.json',
                                        height: height * 0.15,
                                        width: width * 0.5),
                                    Text(
                                      'OTP Sent Successfully',
                                      textScaleFactor: min(
                                          horizontalScale, verticalScale),
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'OTP has been sent to',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(),
                                  ),
                                  Text(
                                    '${_editmobile}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Please enter the OTP in the field below to verify your phone.',
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: verticalScale * 10,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    child: Container(
                                      //height: 20,
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                          min(horizontalScale,
                                              verticalScale) *
                                              10,
                                        ),
                                        child: Text(
                                          'OK',
                                          textScaleFactor: min(
                                              horizontalScale,
                                              verticalScale),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                        color: HexColor('6153D3'),
                                        borderRadius:
                                        BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                      showToast('OTP sent');
                    },
                    verificationFailed: (FirebaseAuthException error) {
                      setState(() {
                        _isloading = false;
                      });
                      showToast(
                          'Error Verifying\nPlease check your Mobile Number and try again');
                      setState(() {
                        _isloading = false;
                      });
                    },
                  );
                } else {}
              },
            ),
          ),
          SizedBox(
            height: verticalScale * 24,
          ),
          Divider(
            thickness: 2,
          ),
          SizedBox(
            height: verticalScale * 24,
          ),
          Center(
              child: Text(
                "Enter OTP",
                textScaleFactor: min(horizontalScale, verticalScale),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )),
          SizedBox(
            height: verticalScale * 14,
          ),
          Form(
            key: _otpkey,
            child: TextFormField(
              controller: otpedit,
              textAlign: TextAlign.center,
              // style: TextStyle(
              //   letterSpacing: 8.0,
              // ),
              //obscureText: true,
              decoration: InputDecoration(
                //hintText: 'Enter One Time Password',
                labelText: 'OTP',
                floatingLabelAlignment: FloatingLabelAlignment.center,
                counterText: '',
                floatingLabelStyle: TextStyle(
                    fontSize: 22*min(horizontalScale, verticalScale),
                    fontWeight: FontWeight.w500,
                    color: HexColor('7B62DF')),
                labelStyle: TextStyle(
                  fontSize:18*min(horizontalScale, verticalScale),
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: HexColor('7B62DF'), width: 2)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: HexColor('7B62DF'), width: 2),
                ),
              ),
              keyboardType: TextInputType.phone,
              maxLength: 6,
              validator: (String? value) {
                if (value!.isEmpty) {
                  return 'OTP is required';
                } else if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                  return 'OTP must be 6 digits only';
                }
                return null;
              },
            ),
          ),
          SizedBox(
            height: verticalScale * 22,
          ),
          Center(
            child: (_verifyloading)
                ? Loading()
                : InkWell(
              child: Container(
                //height: 20,
                child: Padding(
                  padding: EdgeInsets.all(
                    min(horizontalScale, verticalScale) * 8,
                  ),
                  child: Text(
                    'Verify',
                    textScaleFactor: min(horizontalScale, verticalScale),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20),
                  ),
                ),
                decoration: BoxDecoration(
                  color: HexColor('6153D3'),
                  borderRadius: BorderRadius.circular(
                      min(horizontalScale, verticalScale) * 5),
                  boxShadow: [
                    BoxShadow(
                      color: HexColor('6153D3'),
                      blurRadius: 10.0, // soften the shadow
                      offset: Offset(0, 4.0),
                    )
                  ],
                ),
              ),
              onTap: () async {
                if (_otpkey.currentState!.validate()) {
                  setState(() {
                    _verifyloading = true;
                  });
                  FirebaseAuth auth = FirebaseAuth.instance;
                  final code = otpedit.text.trim();
                  try {
                    AuthCredential credential =
                    PhoneAuthProvider.credential(
                        verificationId: verifyid!, smsCode: code);
                    User? firebaseUser=auth.currentUser;
                    // var result =
                    // await auth.signInWithCredential(credential);
                    var result =
                    await firebaseUser!.linkWithCredential(credential);

                    setState(() {
                      _verifyloading = false;
                    });

                    AwesomeDialog(
                      context: context,
                      animType: AnimType.LEFTSLIDE,
                      headerAnimationLoop: true,
                      dialogType: DialogType.SUCCES,
                      showCloseIcon: true,
                      title: 'Verified!',
                      desc:
                      'Your Mobile Number\n ${_editmobile} \nhas been successfully verified!\n Please wait you will be redirected.',
                      btnOkOnPress: () {
                        debugPrint('OnClcik');
                      },
                      btnOkIcon: Icons.check_circle,
                      onDissmissCallback: (type) {
                        debugPrint('Dialog Dissmiss from callback $type');
                      },
                    ).show();

                    var user = result.user;
                    if (user != null) {
                        _firestore.collection('Users')
                            .doc(userprovider.userModel!.id)
                            .update({
                        //'name':_username,
                          'mobilenumber':_editmobile,
                          'phoneVerified':true
                        });
                      await Future.delayed(Duration(seconds: 4));
                      FocusScope.of(context).requestFocus(new FocusNode());
                      await Future.delayed(Duration(milliseconds: 60));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Phone Verified')));
                      userprovider.reloadUserModel();
                        Navigator.pop(context);
                      // await AwesomeNotifications().createNotification(
                      //     content:NotificationContent(
                      //         id:  1234,
                      //         channelKey: 'image',
                      //         title: 'Welcome to CloudyML',
                      //         body: 'It\'s great to have you on CloudyML',
                      //         bigPicture: 'asset://assets/HomeImage.png',
                      //         largeIcon: 'asset://assets/logo2.png',
                      //         notificationLayout: NotificationLayout.BigPicture,
                      //         displayOnForeground: true
                      //     )
                      // );
                      // await Provider.of<UserProvider>(context, listen: false).addToNotificationP(
                      //   title: 'Welcome to CloudyML',
                      //   body: 'It\'s great to have you on CloudyML',
                      //   notifyImage: 'https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/images%2Fhomeimage.png?alt=media&token=2f4abc37-413f-49c3-b43d-03c02696567e',
                      //   NDate: DateFormat('dd-MM-yyyy | h:mm a').format(DateTime.now()),
                      // );
                    } else {
                      setState(() {
                        _verifyloading = false;
                      });
                      showToast('Incorrect OTP\nPlease try again');
                      print("Error");
                    }
                  } catch (e) {
                    setState(() {
                      _verifyloading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    //showToast(e.toString());
                    setState(() {
                      _verifyloading = false;
                    });
                  }
                } else {}
              },
            ),
          ),
        ],
      ),
    );
  }
}
