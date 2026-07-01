import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'emergency_screen.dart';

class AccidentAlertScreen extends StatefulWidget {
  const AccidentAlertScreen({super.key});

  @override
  State<AccidentAlertScreen> createState() => _AccidentAlertScreenState();
}

class _AccidentAlertScreenState extends State<AccidentAlertScreen> {
  int countdown = 10;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    startCountdown();
  }

  void startCountdown() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) return;

      setState(() {
        countdown--;
      });

      if (countdown == 0) {
        timer.cancel();

        await sendEmergencySMS();

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EmergencyScreen()),
        );
      }
    });
  }

  Future<void> sendEmergencySMS() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('contacts')
          .get();

      List<String> phoneNumbers = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        if (data['phone'] != null && data['phone'].toString().isNotEmpty) {
          phoneNumbers.add(data['phone'].toString());
        }
      }

      if (phoneNumbers.isNotEmpty) {
        debugPrint("Contacts found: $phoneNumbers");
        await sendSMS(
          message: 'Accident detected! Please help immediately.',
          recipients: phoneNumbers,
        );

        debugPrint("SMS opened for ${phoneNumbers.length} contacts");
      } else {
        debugPrint("No emergency contacts found");
      }
    } catch (e) {
      debugPrint("SMS Error: $e");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void cancelAlert() {
    timer?.cancel();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 120,
              ),

              const SizedBox(height: 30),

              const Text(
                'Accident Detected!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Emergency alert in $countdown seconds',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 18,
                  ),
                ),

                onPressed: cancelAlert,

                child: const Text(
                  'CANCEL ALERT',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
