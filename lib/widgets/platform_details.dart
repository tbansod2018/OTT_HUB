import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class PlatformDetails extends StatefulWidget {
  const PlatformDetails({super.key, required this.platformName});
  final String platformName;

  @override
  State<PlatformDetails> createState() => _PlatformDetailsState();
}

class _PlatformDetailsState extends State<PlatformDetails> {
  String? _selectedValue;

  void _buySubscription(String platformName, String duration) async {
    try {
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      final userDoc = await userDocRef.get();

      final data = userDoc.data() as Map<String, dynamic>;
      final List<dynamic> subscriptions = data['subscriptions'] ?? [];

      DateTime createdAt = DateTime.now();
      DateTime expiration;

      if (duration == '1 Day') {
        expiration = createdAt.add(const Duration(days: 1));
      } else if (duration == '1 Week') {
        expiration = createdAt.add(const Duration(days: 7));
      } else if (duration == '1 Month') {
        expiration = createdAt.add(const Duration(days: 30));
      } else {
        throw 'Invalid duration';
      }

      final newSubscription = {
        'platform': platformName,
        'duration': duration,
        'createdAt': createdAt,
        'expiration': expiration,
      };

      if (subscriptions.any((sub) => sub['platform'] == platformName)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription already exists'),
          ),
        );
        return;
      }

      subscriptions.add(newSubscription);

      await userDocRef.update({'subscriptions': subscriptions});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Subscription added successfully. Please visit profile',
          ),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
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
