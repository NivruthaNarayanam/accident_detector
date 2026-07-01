import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  int countdown = 10;
  Timer? timer;

  String contactNumber = '';

  @override
  void initState() {
    super.initState();
    initEmergencyFlow();
  }

  Future<void> initEmergencyFlow() async {
    await loadContact();
    startTimer();
  }

  Future<void> loadContact() async {
    final prefs = await SharedPreferences.getInstance();

    final number = prefs.getString('emergency_contact') ?? 'No Contact Saved';

    if (!mounted) return;

    setState(() {
      contactNumber = number;
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }

      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      } else {
        t.cancel();

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Emergency Alert'),
              content: Text('Emergency message sent to:\n\n$contactNumber'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        title: const Text('Emergency Alert'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 120,
              color: Colors.red,
            ),

            const SizedBox(height: 30),

            const Text(
              'Possible Accident Detected',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              '$countdown',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const Text(
              'Sending emergency alert shortly...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 20),

            Text(
              'Emergency Contact: $contactNumber',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 50),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              onPressed: () {
                timer?.cancel();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alert Cancelled - User Safe')),
                );

                Navigator.pop(context);
              },
              child: const Text("I'M SAFE", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
