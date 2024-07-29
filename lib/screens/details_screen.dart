import 'package:flutter/material.dart';
import 'package:ott_hub/widgets/platform_details.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key, required this.platformName});
  final String platformName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          platformName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      body: PlatformDetails(
        platformName: platformName,
      ),
    );
  }
}
