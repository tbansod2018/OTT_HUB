import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class SellSubscription extends StatefulWidget {
  @override
  State<SellSubscription> createState() => _SellSubscriptionState();
}

class _SellSubscriptionState extends State<SellSubscription> {
  var _selectedValue = null;
  DateTime? _selectedDate;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitData() async {
    if (_selectedValue == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a platform',
          ),
        ),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a date"),
        ),
      );
      return;
    }

    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your email"),
        ),
      );
      return;
    }

    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your password"),
        ),
      );
      return;
    }

    // form submission logic
    try {
      await FirebaseFirestore.instance.collection('sell_request').add({
        'platform': _selectedValue,
        'expiry_date': _selectedDate,
        'email': _emailController.text,
        'password': _passwordController.text,
        'created_at': DateTime.now(),
        'owner': FirebaseAuth.instance.currentUser?.uid, // Store only the UID
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data submitted successfully"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to submit data: $e"),
        ),
      );
    }

    // Clear the form
    setState(() {
      _selectedValue = null;
      _selectedDate = null;
      _emailController.clear();
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Lottie.asset(
                'assets/animations/money.json',
                width: 200,
                // fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: const Text('Select a Platform'),
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
                        items: [
                          "Netflix",
                          "Hotstar",
                          "Jio Cinema",
                          "Prime Videos"
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              _selectedDate != null
                                  ? "Plan Expiry Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}"
                                  : "Select expiry date",
                              style: const TextStyle(fontSize: 16.0),
                            ),
                          ),
                          const Icon(Icons.calendar_today,
                              color: Colors.blueAccent),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.all(4),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitData,
                style: const ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll<Color>(Color(0xFF333333)),
                  foregroundColor: MaterialStatePropertyAll<Color>(Colors.red),
                ),
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
