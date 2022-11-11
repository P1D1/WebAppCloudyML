import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../models/course_details.dart';

class OfferScreen extends StatefulWidget {
  const OfferScreen({Key? key}) : super(key: key);

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {

  TextEditingController couponCode = TextEditingController();
  bool isCouponApplied = false;
  String? discountedAmount;

  // Razorpay _razorpay = Razorpay();
  //
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   _razorpay = Razorpay();
  //   _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
  //   _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  //   _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  // }
  //
  // @override
  // void dispose() {
  //   super.dispose();
  //   _razorpay.clear();
  // }
  //
  // void _handlePaymentSuccess(PaymentSuccessResponse response) {
  //   Fluttertoast.showToast(msg: "Success: ${response.paymentId}");
  // }
  // void _handlePaymentError(PaymentFailureResponse response) {
  //   Fluttertoast.showToast(msg: "Failure: ${response.code.toString()} ${response.message}");
  // }
  // void _handleExternalWallet(ExternalWalletResponse response) {
  //   Fluttertoast.showToast(msg: "External: ${response.walletName}");
  // }
  //
  // void openCheckout() async {
  //   var options = {
  //     'key': 'rzp_live_ESC1ad8QCKo9zb',
  //     'amount': 2500,
  //     'name': 'dipen',
  //     'external': ['paytm', 'phonepe'],
  //   };
  //   try{
  //     _razorpay.open(options);
  //   }catch(e) {
  //     print(e.toString());
  //   }
  // }

  @override
  Widget build(BuildContext context) {

    List<CourseDetails> course = Provider.of<List<CourseDetails>>(context);

    String coupon = 'diwali10';

    return Scaffold(
      // body: Container(
      //   child: Column(
      //     children: [
      //       TextField(
      //       decoration: InputDecoration(
      //       suffixIcon: Expanded(
      //         child: TextButton(
      //           onPressed: () {
      //             // openCheckout();
      //           },
      //           child: Text('Pay'), ),
      //       ),
      //   ),
      //   ),
      //     ],
      //   )
      // ),
      body: Container(
        child: Column(
          children: [
            isCouponApplied ? Text('$discountedAmount') : Text(
                course[1].coursePrice),

            TextField(
              controller: couponCode,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                suffixIcon: ElevatedButton(
                    onPressed: () {
                      if (couponCode.text.isNotEmpty && couponCode.text == coupon) {
                        setState(() {
                          isCouponApplied = true;
                          discountedAmount = '1000';
                          Fluttertoast.showToast(msg: 'Discount applied successfully');
                          couponCode.clear();
                        });
                      } else if (couponCode.text != coupon) {
                        couponCode.text.isNotEmpty ? Fluttertoast.showToast(msg: 'Please enter coupon code') : Fluttertoast.showToast(msg: 'Invalid coupon code');
                      } else {
                        Fluttertoast.showToast(msg: 'Please enter coupon code');
                      }

                    },
                    child: Text('Apply coupon'))
              ),
            ),
          ],
        ),
      ),
    );
  }
}
