import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vibration/vibration.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  int secondsLeft = 30;
  Timer? countdownTimer;
  List<String> contacts = [];

  @override
  void initState() {
    super.initState();

    initializeScreen();
    startVibration();
  }

  Future<void> initializeScreen() async {
    await loadContact();
    startCountdown();
  }

  Future<void> startVibration() async {
    bool? hasVibrator = await Vibration.hasVibrator();

    if (hasVibrator == true) {
      Vibration.vibrate(duration: 30000);
    }
  }
  // ---------------- CONTACT ----------------

  Future<void> loadContact() async {
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

      if (!mounted) return;

      setState(() {
        contacts = phoneNumbers;
      });

      debugPrint("Loaded contacts: $contacts");
    } catch (e) {
      debugPrint("Error loading contacts: $e");
    }
  }
  // ---------------- LOCATION ----------------

  Future<String> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return 'Location Disabled';

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return 'Location Permission Denied';
    }

    Position position = await Geolocator.getCurrentPosition();

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    Placemark place = placemarks.first;

    return '${place.locality}, ${place.administrativeArea}';
  }

  Future<String> getLocationLink() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'Location unavailable';
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return 'Location permission denied';
    }

    Position position = await Geolocator.getCurrentPosition();

    return 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
  }
  // ---------------- HISTORY ----------------

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('accident_history') ?? [];

    String location = await getLocation();
    String locationLink = await getLocationLink();
    String formattedTime = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(DateTime.now());

    String entry =
        'Contacts: ${contacts.join(", ")}\n'
        'Location: $location\n'
        'Map Link: $locationLink\n'
        'Time: $formattedTime';

    history.add(entry);

    await prefs.setStringList('accident_history', history);
  }

  // ---------------- SMS ----------------

  Future<void> sendEmergencySMS() async {
    try {
      String locationLink = await getLocationLink();

      await sendSMS(
        message:
            'EMERGENCY ALERT!\n\n'
            'Possible accident detected.\n\n'
            'Live Location:\n'
            '$locationLink\n\n'
            'Please check immediately.',
        recipients: contacts,
      );
    } catch (e) {
      debugPrint('SMS Error: $e');
    }
  }

  // ---------------- COUNTDOWN ----------------

  void startCountdown() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) return;

      setState(() {
        secondsLeft--;
      });

      if (secondsLeft == 0) {
        timer.cancel();
        Vibration.cancel();

        await showAlertSentMessage();
      }
    });
  }

  // ---------------- ALERT ----------------

  Future<void> showAlertSentMessage() async {
    await saveHistory();
    await sendEmergencySMS();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Emergency Alert'),
          content: Text(
            contacts.isEmpty
                ? 'No Contacts Found'
                : 'Emergency Contacts:\n${contacts.join('\n')}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // ---------------- UI ACTIONS ----------------

  void onSafePressed() async {
    countdownTimer?.cancel();

    if (!mounted) return;
    Navigator.pop(context);
    Vibration.cancel();
  }

  // ---------------- DISPOSE ----------------

  @override
  void dispose() {
    countdownTimer?.cancel();

    super.dispose();
  }

  // ---------------- UI ----------------

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
              const Icon(Icons.warning, color: Colors.red, size: 120),

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
                '$secondsLeft',
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Sending emergency alert...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22),
              ),

              const SizedBox(height: 20),

              Text(
                contacts.join('\n'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 50),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 18,
                  ),
                ),
                onPressed: onSafePressed,

                child: const Text('I AM SAFE', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
