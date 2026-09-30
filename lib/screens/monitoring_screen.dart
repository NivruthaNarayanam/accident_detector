import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
import 'dart:async';

import 'countdown_screen.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  double totalForce = 0.0;
  double filteredForce = 0.0;

  static const double alpha = 0.8;

  double x = 0;
  double y = 0;
  double z = 0;

  List<double> forceHistory = [];

  bool alertShown = false;
  DateTime? lastDetectionTime;
  StreamSubscription? accelerometerSubscription;

  // QuickAlert colors
  static const Color navy = Color(0xFF123B78);
  static const Color red = Color(0xFFE53935);
  static const Color background = Color(0xFFF7F9FC);

  @override
  void initState() {
    super.initState();

    accelerometerSubscription = accelerometerEventStream().listen((event) {
      if (!mounted) return;

      setState(() {
        x = event.x;
        y = event.y;
        z = event.z;

        totalForce = sqrt(x * x + y * y + z * z);

        filteredForce = alpha * filteredForce + (1 - alpha) * totalForce;

        forceHistory.add(filteredForce);

        bool canTriggerAccident() {
          if (lastDetectionTime == null) {
            return true;
          }

          return DateTime.now().difference(lastDetectionTime!).inSeconds > 30;
        }

        if (forceHistory.length > 20) {
          forceHistory.removeAt(0);
        }

        if (detectAccident() && !alertShown && canTriggerAccident()) {
          lastDetectionTime = DateTime.now();

          alertShown = true;

          triggerAccidentAlert();
        }
      });
    });
  }

  @override
  void dispose() {
    accelerometerSubscription?.cancel();
    super.dispose();
  }

  void triggerAccidentAlert() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CountdownScreen()),
    );

    if (!mounted) return;

    alertShown = false;
  }

  bool detectAccident() {
    if (forceHistory.length < 20) {
      return false;
    }

    double maxForce = forceHistory.reduce((a, b) => a > b ? a : b);

    double avgForce =
        forceHistory.reduce((a, b) => a + b) / forceHistory.length;

    return maxForce > 18 && avgForce > 12;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF172033)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'QuickAlert',
          style: TextStyle(
            color: Color(0xFF172033),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      // ---------------- BODY ----------------
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),

          child: Column(
            children: [
              // ---------------- LOGO ----------------
              Container(
                width: 82,
                height: 82,
                padding: const EdgeInsets.all(6),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color: navy.withValues(alpha: 0.10),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(19),

                  child: Image.asset('assets/app_icon.png', fit: BoxFit.cover),
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- STATUS ----------------
              const Text(
                'Monitoring Active',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172033),
                ),
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 10,
                    height: 10,

                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    'Accident detection is active',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ---------------- MONITORING STATUS CARD ----------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,

                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: const Icon(
                        Icons.sensors_rounded,
                        color: Colors.green,
                        size: 27,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text(
                            'Sensor Monitoring',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF172033),
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            'Accelerometer is continuously '
                            'monitoring movement',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 25,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ---------------- SENSOR DATA ----------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Live Sensor Data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF172033),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Real-time accelerometer readings',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(child: _sensorValue('X Axis', x)),

                        Expanded(child: _sensorValue('Y Axis', y)),

                        Expanded(child: _sensorValue('Z Axis', z)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),

                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9FC),
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Force',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                totalForce.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: red,
                                ),
                              ),
                            ],
                          ),

                          Container(
                            width: 1,
                            height: 42,
                            color: Colors.grey.shade300,
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Filtered Force',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                filteredForce.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: navy,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ---------------- STOP MONITORING ----------------
              SizedBox(
                width: double.infinity,
                height: 58,

                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: red,
                    foregroundColor: Colors.white,
                    elevation: 3,

                    shadowColor: red.withValues(alpha: 0.25),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),

                  icon: const Icon(Icons.stop_circle_outlined, size: 24),

                  label: const Text(
                    'STOP MONITORING',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 13),

              // ---------------- TEST ACCIDENT ----------------
              SizedBox(
                width: double.infinity,
                height: 54,

                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CountdownScreen(),
                      ),
                    );
                  },

                  style: OutlinedButton.styleFrom(
                    foregroundColor: navy,

                    side: const BorderSide(color: navy, width: 1.4),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),

                  icon: const Icon(Icons.warning_amber_rounded),

                  label: const Text(
                    'TEST ACCIDENT',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Test button is for demonstration purposes',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- SENSOR VALUE WIDGET ----------------

  Widget _sensorValue(String label, double value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          value.toStringAsFixed(2),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF172033),
          ),
        ),
      ],
    );
  }
}
