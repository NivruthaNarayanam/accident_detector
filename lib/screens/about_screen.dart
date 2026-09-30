import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const Color navy = Color(0xFF123B78);
  static const Color red = Color(0xFFE53935);
  static const Color green = Color(0xFF22A06B);
  static const Color background = Color(0xFFF7F9FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        foregroundColor: navy,
        centerTitle: true,
        title: const Text(
          'QuickAlert',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          children: [
            // --------------------------------------------------
            // HEADER
            // --------------------------------------------------
            const SizedBox(height: 8),

            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: red.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.health_and_safety_rounded,
                color: red,
                size: 52,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'About QuickAlert',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Your safety, our priority',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: red,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'A smart accident detection and '
              'emergency assistance system designed '
              'to help reduce response time.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.45,
              ),
            ),

            const SizedBox(height: 26),

            // --------------------------------------------------
            // MISSION CARD
            // --------------------------------------------------
            _buildMissionCard(),

            const SizedBox(height: 28),

            // --------------------------------------------------
            // FEATURES TITLE
            // --------------------------------------------------
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '✨  KEY FEATURES',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: navy,
                  letterSpacing: 0.3,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // --------------------------------------------------
            // FEATURE GRID
            // --------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.warning_rounded,
                    title: 'Accident',
                    subtitle: 'Detection',
                    color: red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.location_on_rounded,
                    title: 'Live',
                    subtitle: 'Location',
                    color: navy,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.notifications_active_rounded,
                    title: 'Emergency',
                    subtitle: 'Alerts',
                    color: red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.local_hospital_rounded,
                    title: 'Nearby',
                    subtitle: 'Hospitals',
                    color: green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.history_rounded,
                    title: 'Accident',
                    subtitle: 'History',
                    color: navy,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.local_police_rounded,
                    title: 'Police',
                    subtitle: 'Dashboard',
                    color: navy,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // EMERGENCY ASSISTANCE
            // --------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: green.withValues(alpha: 0.15)),
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
                      color: green.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: green,
                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 13),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emergency Assistance',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: navy,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Helping connect users with timely assistance.',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --------------------------------------------------
            // FOOTER
            // --------------------------------------------------
            const Text(
              '❤️ Every second counts.',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: navy,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'QuickAlert',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: red,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Detect • Alert • Save',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black45,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MISSION CARD
  // ============================================================

  Widget _buildMissionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [navy, navy.withValues(alpha: 0.90)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.track_changes_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OUR MISSION',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'To reduce emergency response time '
                  'and help users receive timely '
                  'assistance when they need it most.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.45,
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
  // FEATURE CARD
  // ============================================================

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      height: 128,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 24),
          ),

          const Spacer(),

          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
