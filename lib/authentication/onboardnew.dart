import 'dart:math';

import 'package:cloudyml_app2/authentication/SignUpForm.dart';
import 'package:cloudyml_app2/authentication/firebase_auth.dart';
import 'package:cloudyml_app2/authentication/loginform.dart';
import 'package:cloudyml_app2/authentication/onboardbg.dart';
import 'package:cloudyml_app2/authentication/phoneauthnew.dart';
import 'package:cloudyml_app2/globals.dart';
import 'package:cloudyml_app2/models/existing_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:url_launcher/url_launcher.dart';

import '../home.dart';
import '../screens/offerscreen.dart';
import '../widgets/loading.dart';

class Onboardew extends StatefulWidget {
  const Onboardew({Key? key}) : super(key: key);

  @override
  State<Onboardew> createState() => _OnboardewState();
}

class _OnboardewState extends State<Onboardew> {

  bool? googleloading = false;
  bool formVisible = false;
  bool value = false;
  bool phoneVisible = false;
  int _formIndex = 1;

  bool _isHidden = true;
  bool _isLoading = false;
  final _loginkey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;


  void _togglepasswordview() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  // List<ExistingUser> listOfAllExistingUser = [];

  // void getListOfExistingUsers() async {
  //   final rawData = await http.get(Uri.parse('https://script.google.com/macros/s/AKfycbzOsK2DmwO6lA_Vv6zaeZTdZA2G6sgN4RmWl9kdb1AsZ6Sz0oCdiSvvEVoYZqQZe8sx/exec'));
  //   var rawJson = convert.jsonDecode(rawData.body);

  //   rawJson.forEach((json) async {
  //     print(json['name']);
  //     ExistingUser existingUser = ExistingUser();
  //     existingUser.name = json['name'];
  //     existingUser.email = json['email'];
  //     existingUser.courseId = json['courseId'];
  //     listOfAllExistingUser.add(existingUser);
  //   });
  // }

  @override
  void initState() {
    // TODO: implement initState
    // getListOfExistingUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final provider =
    Provider.of<GoogleSignInProvider>(context,
        listen: false);

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    var verticalScale = height / mockUpHeight;
    var horizontalScale = width / mockUpWidth;
    print(height);
    print(width);
    return Scaffold(body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth >= 515) {
        return Stack(
          children: [
            Container(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Color.fromRGBO(35, 0, 79, 1),
                    ),
                  ),
                  Expanded(flex: 1, child: Container()),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(80.00),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      width: 525,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            bottomLeft: Radius.circular(30)),
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            HexColor("440F87"),
                            HexColor("7226D1"),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 40.0, // soften the shadow
                            offset: Offset(
                              0, // Move to right 10  horizontally
                              2.0, // Move to bottom 10 Vertically
                            ),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/logo.png',
                              height: 75,
                              width: 110,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Let's Explore",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 22),
                            ),
                            Text(
                              "Data Science Together!",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 34),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: SvgPicture.asset(
                                  'assets/Frame.svg',
                                  height: verticalScale * 360,
                                  width: horizontalScale * 300,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 325,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30),
                          bottomRight: Radius.circular(30)),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 40.0, // soften the shadow
                          offset: Offset(
                            0, // Move to right 10  horizontally
                            2.0, // Move to bottom 10 Vertically
                          ),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Log in",
                            style: TextStyle(
                                color: HexColor("2C2C2C"),
                                fontWeight: FontWeight.bold,
                                fontSize: 22),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Login if you have already created an ",
                            style: TextStyle(
                                color: HexColor("2C2C2C"),
                                fontWeight: FontWeight.w600,
                                fontSize: 10),
                          ),
                          Text(
                            "account, else click on create account.",
                            style: TextStyle(
                                color: HexColor("2C2C2C"),
                                fontWeight: FontWeight.w600,
                                fontSize: 10),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Email",
                            style: TextStyle(
                                color: HexColor("2C2C2C"),
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Form(
                            key: _loginkey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 30,
                                  child: TextFormField(
                                    autofillHints: [AutofillHints.email],
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                    cursorColor: HexColor('8346E1'),
                                    controller: email,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(10),
                                        hintText: 'Enter Your Email',
                                        errorStyle: TextStyle(fontSize: 0.1),
                                        hintStyle: TextStyle(fontSize: 12),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            borderSide: BorderSide(
                                                color: HexColor('8346E1'),
                                                width: 2)),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          borderSide: BorderSide(
                                              color: HexColor('8346E1'),
                                              width: 2),
                                        ),
                                        suffixIcon: Icon(
                                          Icons.email,
                                          color: HexColor('8346E1'),
                                          size: 20,
                                        )),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Enter email address';
                                      } else if (!RegExp(
                                              r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?"
                                              r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                                          .hasMatch(value)) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Password",
                                  style: TextStyle(
                                      color: HexColor("2C2C2C"),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 30,
                                  child: TextFormField(
                                    autofillHints: [AutofillHints.password],
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                    cursorColor: Colors.purple,
                                    controller: pass,
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(fontSize: 0.1),
                                        contentPadding: EdgeInsets.all(10),
                                        hintText: 'Enter Password',
                                        hintStyle: TextStyle(fontSize: 12),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            borderSide: BorderSide(
                                                color: HexColor('8346E1'),
                                                width: 2)),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          borderSide: BorderSide(
                                              color: HexColor('8346E1'),
                                              width: 2),
                                        ),
                                        suffixIcon: InkWell(
                                          onTap: _togglepasswordview,
                                          child: Icon(
                                            _isHidden
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: HexColor('8346E1'),
                                            size: 20,
                                          ),
                                        ),
                                        errorMaxLines: 2),
                                    obscureText: _isHidden,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Enter the Password';
                                      } else if (!RegExp(
                                              r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                                          .hasMatch(value)) {
                                        return 'Password must have at least one Uppercase, one Lowercase, one special character, and one numeric value';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                InkWell(
                                  onTap: () {
                                    if (email.text.isNotEmpty) {
                                      auth.sendPasswordResetEmail(
                                          email: email.text);
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            Future.delayed(
                                                Duration(seconds: 13), () {
                                              Navigator.of(context).pop(true);
                                            });
                                            return AlertDialog(
                                              title: Center(
                                                child: Column(
                                                  children: [
                                                    Lottie.asset(
                                                        'assets/email.json',
                                                        height: height * 0.15,
                                                        width: width * 0.5),
                                                    Text(
                                                      'Reset Password',
                                                      textScaleFactor: min(
                                                          horizontalScale,
                                                          verticalScale),
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 22,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'An email has been sent to ',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(),
                                                  ),
                                                  Text(
                                                    '${email.text}',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    'Click the link in the email to change password.',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  SizedBox(
                                                    height: verticalScale * 10,
                                                  ),
                                                  Text(
                                                    'Didn\'t get the email?',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    'Check entered email or check spam folder.',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(),
                                                  ),
                                                  TextButton(
                                                      child: Text(
                                                        'Retry',
                                                        textScaleFactor: min(
                                                            horizontalScale,
                                                            verticalScale),
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pop(
                                                            context, true);
                                                      }),
                                                ],
                                              ),
                                            );
                                          });
                                    } else {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                                title: Center(
                                                  child: Text(
                                                    'Error',
                                                    textScaleFactor: min(
                                                        horizontalScale,
                                                        verticalScale),
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                content: Text(
                                                  'Enter email in the email field or check if the email is valid.',
                                                  textAlign: TextAlign.center,
                                                  textScaleFactor: min(
                                                      horizontalScale,
                                                      verticalScale),
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                                actions: [
                                                  TextButton(
                                                      child: Text('Retry'),
                                                      onPressed: () {
                                                        Navigator.pop(
                                                            context, true);
                                                      })
                                                ]);
                                          });
                                    }
                                  },
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      'Forgot Password?',
                                      textScaleFactor:
                                          min(horizontalScale, verticalScale),
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          color: HexColor('8346E1'),
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.start,
                                //   children: [
                                //     Transform.scale(
                                //       scale: 0.6,
                                //       child: Checkbox(
                                //         splashRadius: 5.0,
                                //         fillColor:
                                //             MaterialStateProperty.resolveWith(
                                //                 (states) =>
                                //                     HexColor('8346E1')),
                                //         value: this.value,
                                //         onChanged: (value) {
                                //           setState(() {
                                //             this.value = value!;
                                //           });
                                //         },
                                //         shape: RoundedRectangleBorder(
                                //           borderRadius:
                                //               BorderRadius.circular(4.0),
                                //         ),
                                //       ),
                                //     ),
                                //     SizedBox(width: 5),
                                //     Text(
                                //       "Keep me Logged in",
                                //       style: TextStyle(
                                //           fontSize: 12,
                                //           fontWeight: FontWeight.w600,
                                //           color: Colors.grey),
                                //     )
                                //   ],
                                // ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          _isLoading ? Loading() : ElevatedButton(
                            child: Center(
                              child: Text(
                                'Log in',
                                textScaleFactor:
                                    min(horizontalScale, verticalScale),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: HexColor('8346E1'),
                            ),
                            onPressed: () {
                              if(email.text.isEmpty || pass.text.isEmpty) {
                                Fluttertoast.showToast(msg: "Please enter email or password");
                              }

                              if (_loginkey.currentState!.validate()) {
                                setState(() {
                                  _isLoading = true;
                                });
                                logIn(email.text, pass.text).then((user) async {
                                  if (user != null) {
                                    print(user);
                                    showToast('Logged in Successfully');
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        PageTransition(
                                            duration:
                                                Duration(milliseconds: 200),
                                            curve: Curves.bounceInOut,
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                            child: HomePage()),
                                        (route) => false);
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  } else {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                                title: Center(
                                                  child: Text(
                                                    'Error',
                                                    textScaleFactor: min(
                                                        horizontalScale,
                                                        verticalScale),
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                content: Text(
                                                  '       There is no user record \n corresponding to the identifier.',
                                                  textScaleFactor: min(
                                                      horizontalScale,
                                                      verticalScale),
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                                actions: [
                                                  TextButton(
                                                      child: Text('Retry'),
                                                      onPressed: () {
                                                        Navigator.pop(
                                                            context, true);
                                                      })
                                                ]);
                                          });
                                    }
                                    showToast('Login failed');
                                  }
                                });
                              }
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Don’t have an account? ',
                                  textScaleFactor:
                                      min(horizontalScale, verticalScale),
                                  style: TextStyle(fontSize: 20),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      formVisible = true;
                                      _formIndex = 2;
                                    });
                                  },
                                  child: Center(
                                    child: Text(
                                      'Sign Up',
                                      textScaleFactor:
                                          min(horizontalScale, verticalScale),
                                      style: TextStyle(
                                          fontFamily: 'SemiBold',
                                          color: HexColor('5E1EC0'),
                                          fontSize: 20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: Container(
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Divider(
                                    color: Colors.black,
                                    thickness: 2,
                                  )),
                                  SizedBox(
                                    width: horizontalScale * 10,
                                  ),
                                  Text(
                                    'OR',
                                    textScaleFactor:
                                        min(horizontalScale, verticalScale),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    width: horizontalScale * 10,
                                  ),
                                  Expanded(
                                      child: Divider(
                                    color: Colors.black,
                                    thickness: 2,
                                  )),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          InkWell(
                            onTap: () async {
                              try {
                                setState(() {
                                  googleloading = true;
                                });
                                await provider.googleLogin(
                                  context,
                                   // listOfAllExistingUser,
                                );
                                print(provider);
                                setState(() {
                                  googleloading = false;
                                });
                              } catch (e) {
                                print("Google error is here : ${e.toString()}");
                              }
                            },
                            child:
                            googleloading! ?
                            Center(child: CircularProgressIndicator()) :
                            Expanded(
                              child: Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.black, width: 1),
                                  // boxShadow: [
                                  //   color: Colors.white, //background color of box
                                  //   BoxShadow(
                                  //     color: HexColor('977EFF'),
                                  //     blurRadius: 10.0, // soften the shadow
                                  //     offset: Offset(
                                  //       0, // Move to right 10  horizontally
                                  //       2.0, // Move to bottom 10 Vertically
                                  //     ),
                                  //   )
                                  // ],
                                ),
                                child: googleloading!
                                    ? CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: HexColor("2C2C2C"),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 5,
                                          ),
                                          SvgPicture.asset(
                                            'assets/google.svg',
                                            height: min(horizontalScale,
                                                    verticalScale) *
                                                26,
                                            width: min(horizontalScale,
                                                    verticalScale) *
                                                26,
                                          ),
                                          SizedBox(
                                            width: 35,
                                          ),
                                          Text(
                                            'Continue with Google',
                                            textScaleFactor: min(
                                                horizontalScale, verticalScale),
                                            style: TextStyle(
                                                color: HexColor("2C2C2C"),
                                                fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                child: (formVisible)
                    ? (_formIndex == 1)
                        ? Container(
                            color: Colors.black54,
                            alignment: Alignment.center,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        width * 0.06)),
                                          ),
                                          child: Text(
                                            'Login',
                                            textScaleFactor: min(
                                                horizontalScale, verticalScale),
                                            style: TextStyle(
                                              color: HexColor('6153D3'),
                                              fontSize: 16,
                                            ),
                                          )),
                                      SizedBox(
                                        width: horizontalScale * 17,
                                      ),
                                      IconButton(
                                          color: Colors.white,
                                          onPressed: () {
                                            setState(() {
                                              formVisible = false;
                                            });
                                          },
                                          icon: Icon(Icons.clear))
                                    ],
                                  ),
                                  Container(
                                    child: AnimatedSwitcher(
                                      duration: Duration(milliseconds: 200),
                                      child: LoginForm(
                                        page: "OnBoard",
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.black54,
                            alignment: Alignment.center,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        width * 0.06)),
                                          ),
                                          child: Text('SignUp',
                                              textScaleFactor: min(
                                                  horizontalScale,
                                                  verticalScale),
                                              style: TextStyle(
                                                color: HexColor('6153D3'),
                                                fontSize: 18,
                                              ))),
                                      SizedBox(
                                        width: horizontalScale * 17,
                                      ),
                                      IconButton(
                                          color: Colors.white,
                                          onPressed: () {
                                            setState(() {
                                              formVisible = false;
                                            });
                                          },
                                          icon: Icon(Icons.clear))
                                    ],
                                  ),
                                  Container(
                                    child: AnimatedSwitcher(
                                      duration: Duration(milliseconds: 200),
                                      child: SignUpform(
                                          // listOfAllExistingUser:
                                          //     listOfAllExistingUser,
                                          ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                    : null),
            // AnimatedSwitcher(
            //     duration: Duration(milliseconds: 200),
            //     child: (phoneVisible)
            //         ? Container(
            //       color: Colors.black54,
            //       alignment: Alignment.center,
            //       child: SingleChildScrollView(
            //         child: Column(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             Row(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: [
            //                 ElevatedButton(
            //                     onPressed: () {},
            //                     style: ElevatedButton.styleFrom(
            //                       primary: Colors.white,
            //                       shape: RoundedRectangleBorder(
            //                           borderRadius: BorderRadius.circular(
            //                               width * 0.06)),
            //                     ),
            //                     child: Text('OTP Verification',
            //                         textScaleFactor: min(
            //                             horizontalScale, verticalScale),
            //                         style: TextStyle(
            //                           color: HexColor('6153D3'),
            //                           fontSize: 18,
            //                         ))),
            //                 SizedBox(
            //                   width: horizontalScale * 17,
            //                 ),
            //                 IconButton(
            //                     color: Colors.white,
            //                     onPressed: () {
            //                       setState(() {
            //                         phoneVisible = false;
            //                       });
            //                     },
            //                     icon: Icon(Icons.clear))
            //               ],
            //             ),
            //             Container(
            //               child: AnimatedSwitcher(
            //                 duration: Duration(milliseconds: 200),
            //                 child: PhoneAuthentication(),
            //               ),
            //             )
            //           ],
            //         ),
            //       ),
            //     )
            //         : null)
          ],
        );
      } else {
        return Stack(
          children: [
            Onboardbg(),
            Container(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: verticalScale * 76,
                    ),
                    Center(
                        child: Image.asset(
                      'assets/logo.png',
                      height: verticalScale * 80,
                      width: horizontalScale * 238,
                    )),
                    SizedBox(
                      height: verticalScale * 50,
                    ),
                    RichText(
                        textAlign: TextAlign.center,
                        textScaleFactor: min(horizontalScale, verticalScale),
                        text: TextSpan(
                            style: TextStyle(
                              fontSize: 25,
                            ),
                            children: [
                              TextSpan(text: "Learn "),
                              TextSpan(
                                  text: 'data science \n',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: "and "),
                              TextSpan(
                                  text: 'ML ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: "on the go with \nour "),
                              TextSpan(
                                  text: 'mobile app ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ])),
                    SizedBox(
                      height: verticalScale * 47.44,
                    ),
                    Container(
                      width: horizontalScale * 322,
                      decoration: BoxDecoration(
                          boxShadow: [
                            // color: Colors.white, //background color of box
                            BoxShadow(
                              color: HexColor('977EFF'),
                              blurRadius: 18.0, // soften the shadow
                              offset: Offset(
                                0, // Move to right 10  horizontally
                                10.0, // Move to bottom 10 Vertically
                              ),
                            )
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(
                            min(horizontalScale, verticalScale) * 25,
                          ))),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            horizontalScale * 24.76,
                            verticalScale * 35.56,
                            horizontalScale * 24.24,
                            verticalScale * 35.56),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  formVisible = true;
                                  _formIndex = 1;
                                });
                              },
                              child: Container(
                                height: 45 * verticalScale,
                                width: 273 * horizontalScale,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        min(horizontalScale, verticalScale) *
                                            8),
                                    border: Border.all(
                                        color: HexColor('7B62DF'), width: 2)),
                                child: Center(
                                  child: Text(
                                    'Continue with Email',
                                    textScaleFactor:
                                        min(horizontalScale, verticalScale),
                                    style: TextStyle(
                                        fontFamily: 'SemiBold',
                                        color: Colors.black,
                                        fontSize: 20),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: verticalScale * 21,
                            ),
                            // InkWell(
                            //   onTap: () {
                            //     setState(() {
                            //       phoneVisible = true;
                            //     });
                            //   },
                            //   child: Container(
                            //     height: 45 * verticalScale,
                            //     width: 273 * horizontalScale,
                            //     decoration: BoxDecoration(
                            //         borderRadius: BorderRadius.circular(
                            //             min(horizontalScale, verticalScale) * 8),
                            //         border: Border.all(
                            //             color: HexColor('7B62DF'), width: 2)),
                            //     child: Center(
                            //       child: Text(
                            //         'Continue with Phone',
                            //         textScaleFactor:
                            //             min(horizontalScale, verticalScale),
                            //         style: TextStyle(
                            //             fontFamily: 'SemiBold',
                            //             color: Colors.black,
                            //             fontSize: 20),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // SizedBox(
                            //   height: verticalScale * 21,
                            // ),
                            Row(
                              children: [
                                Expanded(
                                    child: Divider(
                                  color: Colors.black,
                                  thickness: 2,
                                )),
                                SizedBox(
                                  width: horizontalScale * 15,
                                ),
                                Text(
                                  'OR',
                                  textScaleFactor:
                                      min(horizontalScale, verticalScale),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  width: horizontalScale * 15,
                                ),
                                Expanded(
                                    child: Divider(
                                  color: Colors.black,
                                  thickness: 2,
                                )),
                              ],
                            ),
                            SizedBox(
                              height: verticalScale * 21,
                            ),
                            InkWell(
                              onTap: () {
                                try {
                                  setState(() {
                                    googleloading = true;
                                  });
                                  final provider =
                                      Provider.of<GoogleSignInProvider>(context,
                                          listen: false);
                                  provider.googleLogin(
                                    context,
                                    // listOfAllExistingUser,
                                  );
                                  print(provider);
                                  setState(() {
                                    googleloading = false;
                                  });
                                } catch (e) {
                                  print(e);
                                }
                              },
                              child: Container(
                                height: horizontalScale * 45,
                                width: verticalScale * 273,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      min(horizontalScale, verticalScale) * 8),
                                  boxShadow: [
                                    // color: Colors.white, //background color of box
                                    BoxShadow(
                                      color: HexColor('977EFF'),
                                      blurRadius: 10.0, // soften the shadow
                                      offset: Offset(
                                        0, // Move to right 10  horizontally
                                        2.0, // Move to bottom 10 Vertically
                                      ),
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: googleloading!
                                      ? CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.black,
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            SvgPicture.asset(
                                              'assets/google.svg',
                                              height: min(horizontalScale,
                                                      verticalScale) *
                                                  26,
                                              width: min(horizontalScale,
                                                      verticalScale) *
                                                  26,
                                            ),
                                            Text(
                                              'Continue with Google',
                                              textScaleFactor: min(
                                                  horizontalScale,
                                                  verticalScale),
                                              style: TextStyle(
                                                  fontFamily: 'SemiBold',
                                                  color: Colors.black,
                                                  fontSize: 18),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: verticalScale * 44,
                            ),
                            Text(
                              'Don’t have an account?',
                              textScaleFactor:
                                  min(horizontalScale, verticalScale),
                              style: TextStyle(fontSize: 20),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  formVisible = true;
                                  _formIndex = 2;
                                });
                              },
                              child: Center(
                                child: Text(
                                  'Sign Up with Email',
                                  textScaleFactor:
                                      min(horizontalScale, verticalScale),
                                  style: TextStyle(
                                      fontFamily: 'SemiBold',
                                      color: HexColor('0047FF'),
                                      fontSize: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: verticalScale * 73.56,
                    ),
                    Container(
                      child: InkWell(
                        onTap: () async {
                          final Uri params = Uri(
                              scheme: 'mailto',
                              path: 'app.support@cloudyml.com',
                              query: 'subject=Query about App');
                          var mailurl = params.toString();
                          if (await canLaunch(mailurl)) {
                            await launch(mailurl);
                          } else {
                            throw 'Could not launch $mailurl';
                          }
                        },
                        child: Text(
                          'Need Help with Login?',
                          textScaleFactor: min(horizontalScale, verticalScale),
                          style: TextStyle(
                              fontFamily: 'Regular',
                              fontSize: 19,
                              color: Colors.black),
                        ),
                      ),
                    ),
                    // SizedBox(
                    //   height: height*0.0705,
                    // ),
                  ],
                ),
              ),
            ),
            AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                child: (formVisible)
                    ? (_formIndex == 1)
                        ? Container(
                            color: Colors.black54,
                            alignment: Alignment.center,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        width * 0.06)),
                                          ),
                                          child: Text(
                                            'Login',
                                            textScaleFactor: min(
                                                horizontalScale, verticalScale),
                                            style: TextStyle(
                                              color: HexColor('6153D3'),
                                              fontSize: 18,
                                            ),
                                          )),
                                      SizedBox(
                                        width: horizontalScale * 17,
                                      ),
                                      IconButton(
                                          color: Colors.white,
                                          onPressed: () {
                                            setState(() {
                                              formVisible = false;
                                            });
                                          },
                                          icon: Icon(Icons.clear))
                                    ],
                                  ),
                                  Container(
                                    child: AnimatedSwitcher(
                                      duration: Duration(milliseconds: 200),
                                      child: LoginForm(
                                        page: "OnBoard",
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.black54,
                            alignment: Alignment.center,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        width * 0.06)),
                                          ),
                                          child: Text('SignUp',
                                              textScaleFactor: min(
                                                  horizontalScale,
                                                  verticalScale),
                                              style: TextStyle(
                                                color: HexColor('6153D3'),
                                                fontSize: 18,
                                              ))),
                                      SizedBox(
                                        width: horizontalScale * 17,
                                      ),
                                      IconButton(
                                          color: Colors.white,
                                          onPressed: () {
                                            setState(() {
                                              formVisible = false;
                                            });
                                          },
                                          icon: Icon(Icons.clear))
                                    ],
                                  ),
                                  Container(
                                    child: AnimatedSwitcher(
                                      duration: Duration(milliseconds: 200),
                                      child: SignUpform(
                                          // listOfAllExistingUser:
                                          //     listOfAllExistingUser,
                                          ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                    : null),
            // AnimatedSwitcher(
            //     duration: Duration(milliseconds: 200),
            //     child: (phoneVisible)
            //         ? Container(
            //             color: Colors.black54,
            //             alignment: Alignment.center,
            //             child: SingleChildScrollView(
            //               child: Column(
            //                 mainAxisSize: MainAxisSize.min,
            //                 children: [
            //                   Row(
            //                     mainAxisAlignment: MainAxisAlignment.center,
            //                     children: [
            //                       ElevatedButton(
            //                           onPressed: () {},
            //                           style: ElevatedButton.styleFrom(
            //                             primary: Colors.white,
            //                             shape: RoundedRectangleBorder(
            //                                 borderRadius: BorderRadius.circular(
            //                                     width * 0.06)),
            //                           ),
            //                           child: Text('OTP Verification',
            //                               textScaleFactor: min(
            //                                   horizontalScale, verticalScale),
            //                               style: TextStyle(
            //                                 color: HexColor('6153D3'),
            //                                 fontSize: 18,
            //                               ))),
            //                       SizedBox(
            //                         width: horizontalScale * 17,
            //                       ),
            //                       IconButton(
            //                           color: Colors.white,
            //                           onPressed: () {
            //                             setState(() {
            //                               phoneVisible = false;
            //                             });
            //                           },
            //                           icon: Icon(Icons.clear))
            //                     ],
            //                   ),
            //                   Container(
            //                     child: AnimatedSwitcher(
            //                       duration: Duration(milliseconds: 200),
            //                       child: PhoneAuthentication(),
            //                     ),
            //                   )
            //                 ],
            //               ),
            //             ),
            //           )
            //         : null)
          ],
        );
      }
    }));
  }
}
