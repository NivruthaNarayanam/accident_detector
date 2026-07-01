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
      appBar: AppBar(title: const Text('Monitoring Screen'), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            const SizedBox(height: 40),

            const Icon(Icons.sensors, size: 100, color: Colors.blue),

            const SizedBox(height: 30),

            const Text(
              'Monitoring Active',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 40),

            Card(
              elevation: 4,

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [
                    Text(
                      'X Axis: ${x.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Y Axis: ${y.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Z Axis: ${z.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Force: ${totalForce.toStringAsFixed(2)}',

                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      'Filtered: ${filteredForce.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 50),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,

                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              onPressed: () {
                Navigator.pop(context);
              },

              icon: const Icon(Icons.stop),

              label: const Text(
                'STOP MONITORING',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CountdownScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.warning),
              label: const Text(
                'TEST ACCIDENT',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
