import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ott_hub/screens/user_profile.dart';
import 'package:ott_hub/widgets/home_content.dart';
import 'package:ott_hub/widgets/sell_subscription.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List platforms = ['Netflix', 'Hotstar', 'Jio Cinema', 'Prime Videos'];
  int _selectedPageIndex = 0;
  var _appBarTitle = 'OTT HUB';

  @override
  void initState() {
    super.initState();
    _removeExpiredSubscriptions();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
      if (_selectedPageIndex == 1) {
        _appBarTitle = 'Sell';
        _content = SellSubscription();
      } else if (_selectedPageIndex == 2) {
        _appBarTitle = 'Profile';
        _content = const UserProfile();
      } else {
        _appBarTitle = 'OTT HUB';
        _content = HomeContent();
      }
    });
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

  Widget _content = HomeContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color.fromARGB(255, 223, 207, 205),
      // backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        // backgroundColor: Color.fromARGB(255, 170, 148, 143),
        backgroundColor: Colors.red,
        title: Text(
          _appBarTitle,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(
              Icons.exit_to_app,
              // color: Theme.of(context).colorScheme.primary,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: _content,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        onTap: _selectPage,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: ' Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sell),
            label: ' Sell',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle_sharp,
            ),
            label: 'Profile',
          )
        ],
      ),
    );
  }
}
