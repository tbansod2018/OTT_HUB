import 'package:flutter/material.dart';
import 'package:ott_hub/widgets/platform_card.dart';

class HomeContent extends StatelessWidget {
  HomeContent({super.key});
  final List platforms = ['Netflix', 'Hotstar', 'Jio Cinema', 'Prime Videos'];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
        itemCount: 4,
        itemBuilder: (ctx, index) =>
            Platformcard(platformName: platforms[index]),
      ),
    );
  }
}
