import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<String> historyList = [];

  static const Color navy = Color(0xFF123B78);
  static const Color red = Color(0xFFE53935);
  static const Color background = Color(0xFFF7F9FC);

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  // ============================================================
  // LOAD HISTORY
  // ============================================================

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final history = prefs.getStringList('accident_history') ?? [];

    if (!mounted) return;

    setState(() {
      historyList = history.reversed.toList();
    });
  }

  // ============================================================
  // CLEAR HISTORY
  // ============================================================

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('accident_history');

    if (!mounted) return;

    setState(() {
      historyList = [];
    });
  }

  // ============================================================
  // CLEAR HISTORY DIALOG
  // ============================================================

  void showClearDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Text(
            'Clear History',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          content: const Text(
            'Are you sure you want to delete all accident history?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: navy)),
            ),

            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await clearHistory();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // EXTRACT HISTORY DATA
  // ============================================================

  String getHistoryValue(String history, String label) {
    final lines = history.split('\n');

    for (final line in lines) {
      if (line.startsWith(label)) {
        return line.substring(label.length).trim();
      }
    }

    return 'Unavailable';
  }

  // ============================================================
  // OPEN LOCATION
  // ============================================================

  Future<void> openLocation(String mapLink) async {
    try {
      final Uri url = Uri.parse(mapLink);

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open location.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Map opening error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open location.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // ========================================================
      // APP BAR
      // ========================================================
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
          'Accident History',
          style: TextStyle(
            color: Color(0xFF172033),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

        actions: [
          if (historyList.isNotEmpty)
            IconButton(
              tooltip: 'Clear History',
              icon: const Icon(Icons.delete_outline_rounded, color: red),
              onPressed: showClearDialog,
            ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: historyList.isEmpty
          ? _emptyHistory()
          : Column(
              children: [
                // ==================================================
                // SUMMARY
                // ==================================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),

                  child: Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: navy,
                      borderRadius: BorderRadius.circular(20),

                      boxShadow: [
                        BoxShadow(
                          color: navy.withValues(alpha: 0.16),
                          blurRadius: 14,
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
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(15),
                          ),

                          child: const Icon(
                            Icons.history_rounded,
                            color: Colors.white,
                            size: 27,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Accident Records',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                '${historyList.length} '
                                '${historyList.length == 1 ? 'incident' : 'incidents'} recorded',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================================
                // HISTORY LIST
                // ==================================================
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 25),

                    itemCount: historyList.length,

                    itemBuilder: (context, index) {
                      final history = historyList[index];

                      final contacts = getHistoryValue(history, 'Contacts:');

                      final location = getHistoryValue(history, 'Location:');

                      final mapLink = getHistoryValue(history, 'Map Link:');

                      final time = getHistoryValue(history, 'Time:');

                      return _accidentCard(
                        accidentNumber: historyList.length - index,
                        contacts: contacts,
                        location: location,
                        mapLink: mapLink,
                        time: time,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  // ============================================================
  // ACCIDENT CARD
  // ============================================================

  Widget _accidentCard({
    required int accidentNumber,
    required String contacts,
    required String location,
    required String mapLink,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: Colors.grey.shade100),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(17),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            // TITLE
            // ======================================================
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,

                  decoration: BoxDecoration(
                    color: red.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: red,
                    size: 25,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Accident #$accidentNumber',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF172033),
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color: red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: const Text(
                    'ALERT',
                    style: TextStyle(
                      color: red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 17),

            Divider(color: Colors.grey.shade200, height: 1),

            const SizedBox(height: 15),

            // ======================================================
            // CONTACTS
            // ======================================================
            _infoRow(
              icon: Icons.people_outline_rounded,
              title: 'Emergency Contacts',
              value: contacts,
            ),

            const SizedBox(height: 13),

            // ======================================================
            // LOCATION
            // ======================================================
            _infoRow(
              icon: Icons.location_on_outlined,
              title: 'Location',
              value: location,
            ),

            const SizedBox(height: 13),

            // ======================================================
            // TIME
            // ======================================================
            _infoRow(
              icon: Icons.access_time_rounded,
              title: 'Alert Time',
              value: time,
            ),

            // ======================================================
            // MAP BUTTON
            // ======================================================
            if (mapLink != 'Unavailable') ...[
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 45,

                child: OutlinedButton.icon(
                  onPressed: () {
                    openLocation(mapLink);
                  },

                  style: OutlinedButton.styleFrom(
                    foregroundColor: navy,

                    side: const BorderSide(color: navy, width: 1.2),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  icon: const Icon(Icons.map_outlined, size: 20),

                  label: const Text(
                    'VIEW LOCATION LINK',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 35,
          height: 35,

          decoration: BoxDecoration(
            color: navy.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),

          child: Icon(icon, color: navy, size: 19),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF172033),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY HISTORY
  // ============================================================

  Widget _emptyHistory() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 90,
              height: 90,

              decoration: BoxDecoration(
                color: navy.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),

              child: const Icon(Icons.history_rounded, color: navy, size: 45),
            ),

            const SizedBox(height: 20),

            const Text(
              'No Accident History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172033),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Your accident alerts will appear here '
              'when they are detected.',
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
