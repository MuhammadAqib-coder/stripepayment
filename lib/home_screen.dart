import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? paymentData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
              child: ActionChip(
            side: const BorderSide(
              color: Colors.yellowAccent,
            ),
            label: const Text("Pay"),
            onPressed: () async {
              await makePayment();
            },
            labelStyle: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            avatar: const Icon(Icons.paypal),
          ))
        ],
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      paymentData = await createPaymentIntent("300", "USD");
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentData!['client_secret'],
        merchantDisplayName: "Aqib",
        googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: "USD", testEnv: true),
        applePay: const PaymentSheetApplePay(merchantCountryCode: "USD"),
        style: ThemeMode.dark,
      ));
      await Stripe.instance.presentPaymentSheet();
      setState(() {
        paymentData = null;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Successfully Paid')));
    } on StripeException catch (e) {
      print(e.toString());
    } catch (e) {
      print(e.toString());
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        "amount": amount,
        "currency": currency,
        "payment_method_types[]": "card"
      };

      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            "Authorization":
                "Bearer sk_test_51NIP2wLhQTYN6AxCoQKTJ8zlzfvxJ4QP7yzAVtIV56QOmMWBNLtV3ZzKXYNFiCWTiuc87JrQkVRGamA7m4NlABUC00QdVSNifJ",
            "Content-Type": "application/x-www-form-urlencoded"
          });
      return jsonDecode(response.body.toString());
    } catch (e) {
      print(e.toString());
    }
  }
}
