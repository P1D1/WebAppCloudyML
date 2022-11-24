import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/screens/exlusive_offer/constants_offerscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_web/razorpay_web.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Providers/UserProvider.dart';
import '../../globals.dart';
import '../../home.dart';
import '../../models/course_details.dart';

class SeasonOffer extends StatefulWidget {


  const SeasonOffer({Key? key}) : super(key: key);

  @override
  State<SeasonOffer> createState() => _SeasonOfferState();
}

class _SeasonOfferState extends State<SeasonOffer> {

  Timer? countDownTimer;
  Duration myDuration = Duration(days: 5);
  final _loginkey = GlobalKey<FormState>();
  String? name = '';
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  String Id = 'CML1';
  var order_id;

  void getCourseName() async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .get()
        .then((value) {
      setState(() {
        name = value.data()!['name'];
        print('ufbufb--$name');
        print('ufbufb--$courseId');
      });
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    showToast("Payment failed");
    print("Payment Fail");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External wallet");
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {

    showToast("Payment successful");

    addCourseToUser(Id);

    loadCourses();

    pushToHome();
  }

  void addCourseToUser(String id) async {

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(_auth.currentUser!.uid)
        .update({
      'paidCourseNames': Id,
    });

  }

  void loadCourses() async {
    await _firestore.collection("courses").doc(courseId).get().then((value) {

      print(_auth.currentUser!.displayName);

      Map<String, dynamic> groupData = {
        "name": value.data()!['name'],
        "icon": value.data()!["image_url"],
        "mentors": value.data()!["mentors"],
        "student_id": _auth.currentUser!.uid,
        "student_name": _auth.currentUser!.displayName,
      };

      _firestore.collection("groups").add(groupData);

    });
  }

  void pushToHome() {
    // Navigator.push(
    //   context,
    //   PageTransition(
    //     duration: Duration(milliseconds: 400),
    //     curve: Curves.bounceInOut,
    //     type: PageTransitionType.topToBottom,
    //     child: HomePage(),
    //   ),
    // );
    Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
          duration: Duration(milliseconds: 200),
          curve: Curves.bounceInOut,
          type: PageTransitionType.rightToLeftWithFade,
          child: HomePage(),
        ),
            (route) => false);
    print('pushedtohome');
  }

  Future<String> generateOrderId(
      String key, String secret, String amount) async {

    var authn = 'Basic ' + base64Encode(utf8.encode('$key:$secret'));

    var headers = {
      "Access-Control-Allow-Origin": "*",
      'content-type': 'application/json',
      'Accept': '*/*',
      'Authorization': authn,
    };

    var data =
        '{ "amount": $amount, '
        '"currency": "INR", '
        '"receipt": "receipt#R1", '
        '"payment_capture": 1 }'; // as per my experience the receipt doesn't play any role in helping you generate a certain pattern in your Order ID!!

    var res = await http.post(
        Uri.parse('https://api.razorpay.com/v1/orders'),
        headers: headers, body: data);
    if (res.statusCode != 200)
      throw Exception('http.post error: statusCode= ${res.statusCode}');
    print('ORDER ID response => ${res.body}');

    // setState(() {
    //   order_id=json.decode(res.body)['id'].toString();
    // });

    order_id = json.decode(res.body)['id'].toString();

    print(order_id);

    return json.decode(res.body)['id'].toString();
  }

  var _razorpay = Razorpay();

  @override
  void initState() {
    super.initState();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);

    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);

    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    getCourseName();

    startTimer();
    if (myDuration.inDays == 0) {
      stopTimer();
    } else {
      return null;
    }
  }

  void startTimer() {
    countDownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setCountDown();
    });
  }

  void stopTimer() {
    setState(() {
      countDownTimer!.cancel();
    });
  }

  void resetTimer() {
    stopTimer();
    setState(() {
      myDuration = Duration(days: 5);
    });
  }

  setCountDown() {
    final reduceSecs = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecs;
      if (seconds < 0) {
        countDownTimer!.cancel();
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  bool newValue = false;
  String addOnAmount = '';


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    List<CourseDetails> course = Provider.of<List<CourseDetails>>(context);
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final days = strDigits(myDuration.inDays);
    final hours = strDigits(myDuration.inHours.remainder(24));
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));

    String totalAmount = course[1].amount_Payable;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              //timer container
              Container(
                height: screenHeight / 10,
                width: screenWidth,
                color: Colors.deepOrangeAccent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "This offer expires soon. ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'SemiBold',
                      ),
                    ),
                    Container(
                      height: screenHeight / 14,
                      width: screenWidth / 20,
                      decoration: decoration,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$days',
                            style: textStyle1,
                          ),
                          Text(
                            "DAY",
                            style: textStyle2,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Container(
                      height: screenHeight / 14,
                      width: screenWidth / 20,
                      decoration: decoration,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$hours', style: textStyle1),
                          Text("HR", style: textStyle2),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Container(
                      height: screenHeight / 14,
                      width: screenWidth / 20,
                      decoration: decoration,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$minutes', style: textStyle1),
                          Text("MIN", style: textStyle2),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Container(
                      height: screenHeight / 14,
                      width: screenWidth / 20,
                      decoration: decoration,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$seconds', style: textStyle1),
                          Text("SEC", style: textStyle2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              //this is for secure checkout box
              Container(
                height: screenHeight / 6,
                width: screenWidth,
                color: Colors.grey[300],
                padding: EdgeInsets.only(top: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield_outlined),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          'Secure Checkout With CloudyML',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SemiBold'),
                        )
                      ],
                    ),
                    Text('Enter details to complete purchase.')
                  ],
                ),
              ),
              //  this is for course summary and payment details
              Container(
                child: Row(
                  children: [
                    Container(
                      height: screenHeight * 1.3,
                      width: screenWidth / 1.7,
                      padding: EdgeInsets.all(25),
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Mega Combo Course Package",
                            style: TextStyle(fontSize: 18, fontFamily: 'SemiBold'),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 15),
                            child: Container(
                              height: screenHeight / 7,
                              width: screenWidth,
                              padding: EdgeInsets.only(left: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border:
                                    Border.all(color: Colors.black26, width: 1),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course[1].courseName,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    course[1].coursePrice,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            'Get Our "Job Hunting Course" Too (Early Bird Access)',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 10),
                            child: Container(
                              height: screenHeight / 5,
                              width: screenWidth,
                              padding: EdgeInsets.only(left: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border:
                                    Border.all(color: Colors.black26, width: 1),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        splashRadius: 20,
                                          value: newValue,
                                          onChanged: (value) {
                                            setState(() {
                                              newValue = !newValue;
                                              addOnAmount = (int.parse(course[1].amount_Payable) + 5500).toString();
                                              print(addOnAmount);
                                              print(newValue);
                                            });
                                          }),
                                      Expanded(child: Text('Learn Practical Ways To Get Jobs in Data Science & Analytics Domain with our JOB HUNTING COURSE. Claim Now !')),
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  Text('      ₹5500/-', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Text(
                              "Your basic information",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Form(
                              key: _loginkey,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 40,
                                        width: screenWidth / 4,
                                        child: TextFormField(
                                          autofillHints: [AutofillHints.namePrefix],
                                          controller: firstNameC,
                                          decoration: textFormFieldDecoration
                                              .copyWith(hintText: 'First Name'),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          height: 40,
                                          child: TextFormField(
                                            autofillHints: [AutofillHints.nameSuffix],
                                            controller: lastNameC,
                                            decoration: textFormFieldDecoration
                                                .copyWith(
                                                    hintText: 'Last Name'),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 15, bottom: 10),
                                    child: SizedBox(
                                      height: 40,
                                      width: screenWidth,
                                      child: TextFormField(
                                        autofillHints: [AutofillHints.email],
                                        controller: emailC,
                                        decoration:
                                            textFormFieldDecoration.copyWith(
                                                hintText: 'Email Address'),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5, bottom: 10),
                                    child: SizedBox(
                                      height: 40,
                                      width: screenWidth,
                                      child: TextFormField(
                                        autofillHints: [AutofillHints.telephoneNumber],
                                        controller: phoneNumberC,
                                        decoration: textFormFieldDecoration
                                            .copyWith(hintText: 'Phone Number'),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 30, bottom: 15.0),
                            child: Text(
                              "Your payment information",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          InkWell(
                            onTap: () async {

                              var options =  {

                                'key': 'rzp_live_ESC1ad8QCKo9zb',
                                'amount':
                                newValue ? (int.parse(addOnAmount) * 100).toString() : (int.parse(totalAmount) * 100).toString(), //amount is paid in paises so pay in multiples of 100
                                'name': course[1].courseDescription,
                                'description': course[1].courseName,
                                'timeout': 300, //in seconds
                                'order_id': order_id,
                                'prefill': {
                                  'contact': userProvider.userModel!.mobile,
                                  // '7003482660', //original number and email
                                  'email': userProvider.userModel!.email,
                                  // 'cloudyml.com@gmail.com'
                                  // 'test@razorpay.com'
                                  'name':userProvider.userModel!.name
                                },
                                'notes':{
                                  'contact': userProvider.userModel!.mobile,
                                  'email': userProvider.userModel!.email,
                                  'name':userProvider.userModel!.name
                                }
                              };

                              order_id = await generateOrderId('rzp_live_ESC1ad8QCKo9zb',
                                  'D5fscRQB6i7dwCQlZybecQND', newValue ? addOnAmount : totalAmount);

                              print('order id is out--$order_id');

                              try{
                                _razorpay.open(options);
                              }catch (e){
                                Fluttertoast.showToast(msg: e.toString());
                              }

                            },
                            child: Container(
                              height: screenHeight / 10,
                              width: screenWidth,
                              padding: EdgeInsets.only(left: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border:
                                    Border.all(color: Colors.black26, width: 1),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/razorpay1.jpg",
                                    fit: BoxFit.fill,
                                    height: 45,
                                    width: 45,
                                  ),
                                  Text(
                                    "Pay with Razorpay",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Wrap(
                              children: [
                                Text(
                                  "By clicking Complete Order you agree to the ",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Text(
                                    "Terms of Service ",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Text(
                                  "and ",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                                InkWell(
                                  onTap: () {

                                  },
                                  child: Text(
                                    "Privacy Policy.",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Container(
                              height: screenHeight / 12,
                              width: screenWidth,
                              child: ElevatedButton(
                                onPressed: () {},
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10.0, bottom: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Complete Order',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Icon(
                                          Icons.arrow_circle_right_outlined,
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: screenHeight * 1.3,
                        color: Colors.blue[100],
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 25.0, right: 25, left: 25),
                          child: Column(
                            children: [
                              // payment window box
                              Container(
                                width: screenWidth,
                                height: newValue ? screenHeight / 1.6 : screenHeight/2.5,
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Order Summary",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                    SizedBox(height: 15,),
                                    Text(
                                      "Mega Combo Course Package",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                    ),
                                    SizedBox(height: 15,),
                                    Divider(
                                      color: Colors.blue[100],
                                      thickness: 1.0,
                                    ),
                                    SizedBox(height: 10,),
                                    Row(
                                      children: [
                                        Expanded(child: Text(course[1].courseName)),
                                        Text('₹${course[1].amount_Payable}')
                                      ],
                                    ),
                                    SizedBox(height: 10,),
                                    newValue
                                        ? Divider(
                                            color: Colors.blue[100],
                                            thickness: 1.0,
                                          )
                                        : SizedBox(),
                                    newValue ? SizedBox(height: 15,) : SizedBox(),
                                    newValue
                                        ? Row(
                                            children: [
                                              Expanded(
                                                  child: Text("Learn Practical Ways To Get Jobs in Data Science & Analytics Domain with our JOB HUNTING COURSE. Claim Now !")),
                                              Text("₹5500")
                                            ],
                                          )
                                        : SizedBox(),
                                    newValue ? SizedBox(height: 15,) : SizedBox(),
                                    Divider(
                                      color: Colors.blue[100],
                                      thickness: 1.0,
                                    ),
                                    SizedBox(height: 10,),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: Text(
                                          "Total",
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                                        Text(newValue ? "₹$addOnAmount" : '₹$totalAmount',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 25.0, bottom: 15),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                    child: Text("Have a Coupon Code?")),
                              ),
                              // coupon code box
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: SizedBox(
                                      height: 40,
                                        width: screenWidth/3.5,
                                        child: TextField(
                                          decoration: textFormFieldDecoration.copyWith(
                                            hintText: 'Enter coupon code',
                                            fillColor: Colors.white,
                                            filled: true,
                                          ),

                                        )),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        child: Text('Apply', style: TextStyle(fontSize: 12),), style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurpleAccent,
                                      ),),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: screenHeight/13,
                width: screenWidth,
                color: Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
