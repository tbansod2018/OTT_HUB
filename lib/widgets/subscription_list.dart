import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubscriptionList extends StatelessWidget {
  const SubscriptionList({super.key});

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Subscription Details'),
          content: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Email: test@otthub.com'),
              SizedBox(height: 8.0),
              Text('Password: testOtt@123'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('No subscriptions found'));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final List<dynamic> subscriptions = data['subscriptions'] ?? [];
        if (subscriptions.isEmpty) {
          return const Center(child: Text('No subscriptions found'));
        }

        // Sort subscriptions by expiration date
        subscriptions.sort((a, b) {
          final expirationA = (a['expiration'] as Timestamp).toDate();
          final expirationB = (b['expiration'] as Timestamp).toDate();
          return expirationA.compareTo(expirationB);
        });

        // Define a DateFormat for the desired format
        final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

        return ListView.builder(
          itemCount: subscriptions.length,
          itemBuilder: (context, index) {
            final sub = subscriptions[index];
            final platform = sub['platform'];
            final duration = sub['duration'];
            final expiration = (sub['expiration'] as Timestamp).toDate();

            return Container(
              margin: const EdgeInsets.symmetric(
                  vertical: 4.0, horizontal: 8.0), // Margin around each tile
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  Color.fromARGB(255, 207, 229, 228),
                  Color.fromARGB(255, 235, 191, 179)
                ]), // Background color of each tile
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2), // changes position of shadow
                  ),
                ],
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.all(16.0), // Padding inside each tile
                title: Text(
                  '$platform - $duration',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Expires on: ${dateFormat.format(expiration)}'),
                leading: IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () => _showDetailsDialog(context),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
