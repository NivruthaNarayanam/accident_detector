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
import 'package:audioplayers/audioplayers.dart';
import 'nearby_hospitals_screen.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  // ============================================================
  // COUNTDOWN
  // ============================================================

  int secondsLeft = 45;
  Timer? countdownTimer;

  List<String> contacts = [];
  final AudioPlayer alertPlayer = AudioPlayer();
  Timer? soundTimer;

  // QuickAlert colors
  static const Color navy = Color(0xFF123B78);
  static const Color red = Color(0xFFE53935);
  static const Color green = Color(0xFF22A06B);
  static const Color background = Color(0xFFF7F9FC);

  @override
  void initState() {
    super.initState();

    initializeScreen();
    startVibration();
    startAlertSound();
  }

  // ============================================================
  // INITIALIZATION
  // ============================================================

  Future<void> initializeScreen() async {
    await loadContact();
    startCountdown();
  }

  // ============================================================
  // VIBRATION
  // ============================================================

  Future<void> startVibration() async {
    bool? hasVibrator = await Vibration.hasVibrator();

    if (hasVibrator == true) {
      Vibration.vibrate(duration: 45000);
    }
  }
  // ============================================================
  // ALERT SOUND
  // ============================================================

  Future<void> startAlertSound() async {
    try {
      await alertPlayer.setReleaseMode(ReleaseMode.loop);

      await alertPlayer.play(AssetSource('sounds/emergency_beep.wav'));

      soundTimer = Timer(const Duration(seconds: 45), () async {
        await alertPlayer.stop();
      });
    } catch (e) {
      debugPrint("Alert sound error: $e");
    }
  }
  // ============================================================
  // CONTACT
  // ============================================================

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

  // ============================================================
  // LOCATION
  // ============================================================

  Future<String> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return 'Location Disabled';
    }

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

    return 'https://maps.google.com/?q='
        '${position.latitude},${position.longitude}';
  }

  // ============================================================
  // FIRESTORE ACCIDENT ALERT
  // ============================================================

  Future<void> saveAccidentAlert() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        debugPrint("Location services are disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint("Location permission denied.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition();

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final place = placemarks.first;

      final locationName = '${place.locality}, ${place.administrativeArea}';

      await FirebaseFirestore.instance.collection('accident_alerts').add({
        'userId': user.uid,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'location': locationName,
        'locationLink':
            'https://maps.google.com/?q='
            '${position.latitude},${position.longitude}',
        'contacts': contacts,
        'status': 'Active',
        'timestamp': FieldValue.serverTimestamp(),
      });

      debugPrint("Accident alert saved to Firestore.");
    } catch (e) {
      debugPrint("Firestore Alert Error: $e");
    }
  }

  // ============================================================
  // HISTORY
  // ============================================================

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

  // ============================================================
  // SMS
  // ============================================================

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

  // ============================================================
  // COUNTDOWN
  // ============================================================

  void startCountdown() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) return;

      setState(() {
        secondsLeft--;
      });

      if (secondsLeft == 0) {
        timer.cancel();

        Vibration.cancel();
        soundTimer?.cancel();

        await alertPlayer.stop();

        await showAlertSentMessage();
      }
    });
  }

  // ============================================================
  // ALERT SENT
  // ============================================================

  Future<void> showAlertSentMessage() async {
    await saveHistory();

    await sendEmergencySMS();

    await saveAccidentAlert();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.emergency, color: red, size: 38),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Emergency Alert',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  contacts.isEmpty
                      ? 'No emergency contacts found.'
                      : 'Emergency alert processed for '
                            '${contacts.length} registered '
                            'contact${contacts.length == 1 ? '' : 's'}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // SAFE BUTTON
  // ============================================================

  void onSafePressed() async {
    countdownTimer?.cancel();

    Vibration.cancel();
    await alertPlayer.stop();
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: green,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Are you safe?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Choose an option to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),

                const SizedBox(height: 22),

                // CANCEL ALERT
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('CANCEL ALERT'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: green,
                      side: const BorderSide(color: green, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // MEDICAL ASSISTANCE
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(dialogContext);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NearbyHospitalsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.local_hospital_outlined),
                    label: const Text('NEED MEDICAL ASSISTANCE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // COUNTDOWN CIRCLE
  // ============================================================

  Widget buildCountdownCircle() {
    double progress = secondsLeft / 45;

    return SizedBox(
      width: 190,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 190,
            height: 190,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 10,
              backgroundColor: red.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(red),
            ),
          ),

          Container(
            width: 158,
            height: 158,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: red.withValues(alpha: 0.12),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$secondsLeft',
                  style: const TextStyle(
                    fontSize: 54,
                    fontWeight: FontWeight.bold,
                    color: red,
                  ),
                ),
                const Text(
                  'SECONDS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.black54,
                  ),
                ),
                const Text(
                  'REMAINING',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black45,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMERGENCY CONTACT CARD
  // ============================================================

  Widget buildContactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: navy.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: navy.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.groups_outlined, color: navy, size: 25),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  contacts.isEmpty
                      ? 'No contacts registered'
                      : '${contacts.length} contact'
                            '${contacts.length == 1 ? '' : 's'} registered',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),

          Icon(
            contacts.isEmpty ? Icons.warning_amber_rounded : Icons.check_circle,
            color: contacts.isEmpty ? Colors.orange : green,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ECG VISUAL
  // ============================================================

  Widget buildECG() {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: CustomPaint(painter: _ECGPainter()),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    countdownTimer?.cancel();
    soundTimer?.cancel();

    Vibration.cancel();
    alertPlayer.dispose();

    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Column(
              children: [
                // ------------------------------------------------
                // LOGO
                // ------------------------------------------------
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: navy.withValues(alpha: 0.10),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        'assets/app_icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'QUICKALERT',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    color: navy,
                  ),
                ),

                const SizedBox(height: 28),

                // ------------------------------------------------
                // WARNING ICON
                // ------------------------------------------------
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: red.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: red,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'ACCIDENT DETECTED',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: navy,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Please confirm your safety',
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),

                const SizedBox(height: 26),

                // ------------------------------------------------
                // COUNTDOWN
                // ------------------------------------------------
                buildCountdownCircle(),

                const SizedBox(height: 22),

                // ------------------------------------------------
                // ECG
                // ------------------------------------------------
                buildECG(),

                const SizedBox(height: 8),

                const Text(
                  'Emergency alert will be sent if there is no response.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.black45),
                ),

                const SizedBox(height: 22),

                // ------------------------------------------------
                // CONTACT CARD
                // ------------------------------------------------
                buildContactCard(),

                const SizedBox(height: 18),

                // ------------------------------------------------
                // SAFE BUTTON
                // ------------------------------------------------
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton.icon(
                    onPressed: onSafePressed,
                    icon: const Icon(Icons.check_circle_outline, size: 25),
                    label: const Text(
                      'I AM SAFE',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: green.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'QuickAlert • Stay Safe',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black38,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// ECG PAINTER
// ================================================================

class _ECGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE53935).withValues(alpha: 0.75)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    final double centerY = size.height / 2;

    path.moveTo(0, centerY);

    path.lineTo(size.width * 0.20, centerY);

    path.lineTo(size.width * 0.25, centerY - 2);

    path.lineTo(size.width * 0.29, centerY);

    path.lineTo(size.width * 0.33, centerY);

    path.lineTo(size.width * 0.37, centerY - 25);

    path.lineTo(size.width * 0.41, centerY + 16);

    path.lineTo(size.width * 0.45, centerY - 7);

    path.lineTo(size.width * 0.49, centerY);

    path.lineTo(size.width * 0.67, centerY);

    path.lineTo(size.width * 0.72, centerY - 3);

    path.lineTo(size.width * 0.76, centerY);

    path.lineTo(size.width * 0.80, centerY);

    path.lineTo(size.width * 0.84, centerY - 20);

    path.lineTo(size.width * 0.88, centerY + 12);

    path.lineTo(size.width * 0.92, centerY - 5);

    path.lineTo(size.width, centerY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
