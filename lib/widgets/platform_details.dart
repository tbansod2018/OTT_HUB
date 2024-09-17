import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:razorpay_flutter/razorpay_flutter.dart';

class PlatformDetails extends StatefulWidget {
  const PlatformDetails({super.key, required this.platformName});
  final String platformName;

  @override
  State<PlatformDetails> createState() => _PlatformDetailsState();
}

class _PlatformDetailsState extends State<PlatformDetails> {
  String? _selectedValue;
  final razorpay = Razorpay();

  late String _duration;
  late String _platformName;

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Fluttertoast.showToast(msg: "Payment Success, visit profile");

    // Add subscription to Firestore
    try {
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      final userDoc = await userDocRef.get();

      final data = userDoc.data() as Map<String, dynamic>;
      final List<dynamic> subscriptions = data['subscriptions'] ?? [];

      DateTime createdAt = DateTime.now();
      DateTime expiration;

      if (_duration == '1 Day') {
        expiration = createdAt.add(const Duration(days: 1));
      } else if (_duration == '1 Week') {
        expiration = createdAt.add(const Duration(days: 7));
      } else if (_duration == '1 Month') {
        expiration = createdAt.add(const Duration(days: 30));
      } else {
        throw 'Invalid duration';
      }

      final newSubscription = {
        'platform': _platformName,
        'duration': _duration,
        'createdAt': createdAt,
        'expiration': expiration,
      };

      subscriptions.add(newSubscription);

      await userDocRef.update({'subscriptions': subscriptions});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
          ),
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "Payment Failed");
  }

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
  }

  void _makePayment(int amount) {
    var options = {
      'key': 'rzp_test_GcZZFDPP0jHtC4',
      'amount': amount,
      'name': 'OTT HUB',
      'description': widget.platformName,
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'}
    };
    razorpay.open(options);
  }

  void _buySubscription(String platformName, String duration) async {
    try {
      // Retrieve the user's document reference
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid);

      // Fetch the user document
      final userDoc = await userDocRef.get();

      // Get the user's subscriptions
      final data = userDoc.data() as Map<String, dynamic>;
      final List<dynamic> subscriptions = data['subscriptions'] ?? [];

      // Check if the user already has a subscription for the selected platform
      bool subscriptionExists =
          subscriptions.any((sub) => sub['platform'] == platformName);

      if (subscriptionExists) {
        // Show a message if the subscription already exists
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription already exists'),
          ),
        );
        return;
      }

      // If no existing subscription, proceed to payment
      int amount = 0;
      if (duration == '1 Week') {
        amount = 90;
      } else if (duration == '1 Month') {
        amount = 140;
      } else if (duration == '1 Day') {
        amount = 60;
      }

      _duration = duration;
      _platformName = platformName;

      // Make payment
      _makePayment(amount);
    } catch (error) {
      Fluttertoast.showToast(msg: 'An error occurred');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);

    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Image(
              image: AssetImage('assets/images/ott.png'),
              // height: 150,
              width: double.infinity,
              fit: BoxFit.cover, // Make the image cover the available space
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: Colors.blueAccent,
                  width: 2,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: const Text('Select an Plan'),
                  value: _selectedValue,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down,
                      color: Colors.blueAccent),
                  iconSize: 36,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  dropdownColor: Colors.blue.shade50,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedValue = newValue;
                    });
                  },
                  items: ["1 Day", "1 Week", "1 Month"]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.all(4),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_selectedValue == null) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please Select Plan',
                      ),
                    ),
                  );
                  return;
                }
                _buySubscription(widget.platformName, _selectedValue!);
              },
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(
                    Color(0xFF333333)), // Light black color
                foregroundColor: MaterialStatePropertyAll<Color>(
                    Colors.red), // Red text color
              ),
              child: const Text('Buy'),
            ),
          ),
        ],
      ),
    );
  }
}
