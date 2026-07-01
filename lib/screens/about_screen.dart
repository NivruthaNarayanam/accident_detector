import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About App'), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Center(
              child: Icon(
                Icons.health_and_safety,
                size: 100,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 20),

            const Center(
              child: Text(
                'Accident Predictor',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Version 1.0',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const Text(
              'Features',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            const Text('• Accident Detection'),
            const Text('• Emergency Contact Alerts'),
            const Text('• GPS Location Tracking'),
            const Text('• Accident History Storage'),
            const Text('• Countdown Safety Confirmation'),

            const SizedBox(height: 30),

            const Text(
              'Developed using Flutter',
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
