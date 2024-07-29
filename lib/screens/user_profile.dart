import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ott_hub/widgets/subscription_list.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String userImage = '';
  bool isLoading = true;
  String userName = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _removeExpiredSubscriptions();
  }

  Future<void> _removeExpiredSubscriptions() async {
    try {
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      final userDoc = await userDocRef.get();

      final data = userDoc.data() as Map<String, dynamic>;
      final List<dynamic> subscriptions = data['subscriptions'] ?? [];
      final now = DateTime.now();

      final updatedSubscriptions = subscriptions.where((sub) {
        final expiration = (sub['expiration'] as Timestamp).toDate();
        return expiration.isAfter(now);
      }).toList();

      await userDocRef.update({'subscriptions': updatedSubscriptions});
    } catch (error) {
      print('Error removing expired subscriptions: $error');
    }
  }

  Future<void> fetchUserData() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    // print(currentUser);
    if (currentUser != null) {
      try {
        final DocumentSnapshot<Map<String, dynamic>> userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .get();

        if (userDoc.exists) {
          setState(() {
            userImage = userDoc.data()?['image_url'] ?? '';
            userName = userDoc.data()?['username'] ?? '';
          });
        }
        // print(userDoc.data());
      } catch (error) {
        print('Error fetching user image: $error');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(4),
      child: isLoading
          ? const CircularProgressIndicator()
          : Column(
              // mainAxisAlignment: MainAxisAlignment.center,

              children: [
                const SizedBox(
                  height: 10,
                ),
                CircleAvatar(
                  radius: 80,
                  backgroundImage: userImage.isNotEmpty
                      ? NetworkImage(userImage)
                      : null, // Set backgroundImage to null if no image
                  backgroundColor: userImage.isEmpty
                      ? Colors.grey[200]
                      : Colors
                          .transparent, // Set background color to gray if no image
                  child: userImage.isEmpty
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null, // Optionally add an icon if no image
                ),
                const SizedBox(height: 10),
                Text(
                  userName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Expanded(
                  child: SubscriptionList(),
                )
              ],
            ),
    );
  }
}
