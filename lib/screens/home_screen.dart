import 'package:flutter/material.dart';
import 'monitoring_screen.dart';
import 'history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'about_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'emergency_contacts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';
  int totalAlerts = 0;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> history = prefs.getStringList('accident_history') ?? [];

    setState(() {
      totalAlerts = history.length;
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        userName = user.email!.split('@')[0];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),

              const Icon(Icons.health_and_safety, size: 100, color: Colors.red),

              const SizedBox(height: 20),

              Text(
                'Welcome $userName',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Statistics',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        'Total Alerts: $totalAlerts',
                        style: const TextStyle(fontSize: 18),
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MonitoringScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('START MONITORING'),
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EmergencyContactsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.contact_phone),
                label: const Text('EMERGENCY CONTACTS'),
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('ACCIDENT HISTORY'),
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.info),
                label: const Text('ABOUT APP', style: TextStyle(fontSize: 18)),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                child: const Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
