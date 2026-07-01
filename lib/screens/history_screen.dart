import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<String> historyList = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final history = prefs.getStringList('accident_history') ?? [];

    if (!mounted) return;

    setState(() {
      historyList = history.reversed.toList();
    });
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('accident_history');

    if (!mounted) return;

    setState(() {
      historyList = [];
    });
  }

  void showClearDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear History'),
          content: const Text(
            'Are you sure you want to delete all accident history?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await clearHistory();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accident History'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showClearDialog();
            },
          ),
        ],
      ),
      body: historyList.isEmpty
          ? const Center(
              child: Text(
                'No Accident History Available',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 15),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.shade100,
                      child: const Icon(Icons.warning, color: Colors.red),
                    ),
                    title: Text(
                      'Accident #${historyList.length - index}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(historyList[index]),
                  ),
                );
              },
            ),
    );
  }
}
