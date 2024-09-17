import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ott_hub/screens/details_screen.dart';

class Platformcard extends StatelessWidget {
  const Platformcard({super.key, required this.platformName});
  final String platformName;

  void getCreadencials() {
    final data = FirebaseFirestore.instance.collection('platforms').snapshots();
    print(data);
  }

  @override
  Widget build(BuildContext context) {
    var imageName = "";
    if (platformName == 'Netflix') {
      imageName = 'netflix.jpg';
    } else if (platformName == 'Hotstar') {
      imageName = 'hotstar.jpeg';
    } else if (platformName == 'Jio Cinema') {
      imageName = 'jioCinema.png';
    } else {
      imageName = 'primeVideos.png';
    }

    return Container(
      margin: const EdgeInsets.all(5), // Add some margin to the container
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 50, 50, 50),
            Color.fromARGB(255, 20, 20, 20)
          ], // Gradient colors
          begin: Alignment.topLeft, // Gradient starting point
          end: Alignment.bottomRight, // Gradient ending point
        ),
        borderRadius:
            BorderRadius.circular(15.0), // Border radius for rounded corners
      ),
      child: Card(
        color: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              15.0), // Match the border radius of the container
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Add padding inside the card
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image(
                  image: AssetImage('assets/images/$imageName'),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  platformName,
                  style: const TextStyle(
                    fontSize: 20.0, // Increase font size for better readability
                    fontWeight: FontWeight.bold,
                    color: Colors
                        .white, // Change text color to stand out on the gradient background
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // print('button pressed');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailsScreen(platformName: platformName),
                      ),
                    );
                  },
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll<Color>(
                        Color(0xFF333333)), // Light black color
                    foregroundColor: MaterialStatePropertyAll<Color>(
                        Colors.red), // Red text color
                  ),
                  child: Text('Get Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
