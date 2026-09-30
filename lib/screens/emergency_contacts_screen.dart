import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  static const Color navy = Color(0xFF123B78);
  static const Color red = Color(0xFFE53935);
  static const Color background = Color(0xFFF7F9FC);

  Stream<QuerySnapshot> getContacts() {
    final user = FirebaseAuth.instance.currentUser!;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('contacts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> saveContact() async {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter both name and phone number'),
          backgroundColor: red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('contacts')
          .add({
            'name': nameController.text.trim(),
            'phone': phoneController.text.trim(),
            'createdAt': Timestamp.now(),
          });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Emergency contact added successfully'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      nameController.clear();
      phoneController.clear();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save contact: $e'),
          backgroundColor: red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

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
          'Emergency Contacts',
          style: TextStyle(
            color: Color(0xFF172033),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------- HEADER ----------------
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: navy,
                        borderRadius: BorderRadius.circular(22),

                        boxShadow: [
                          BoxShadow(
                            color: navy.withValues(alpha: 0.18),
                            blurRadius: 15,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),

                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,

                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(16),
                            ),

                            child: const Icon(
                              Icons.contact_phone_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),

                          const SizedBox(width: 15),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Stay Connected',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 5),

                                Text(
                                  'These contacts will receive '
                                  'emergency alerts.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ---------------- ADD CONTACT ----------------
                    const Text(
                      'Add Emergency Contact',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF172033),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Add someone you trust to receive accident alerts.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Name field
                    _inputField(
                      controller: nameController,
                      label: 'Contact Name',
                      hint: 'Enter contact name',
                      icon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.name,
                    ),

                    const SizedBox(height: 13),

                    // Phone field
                    _inputField(
                      controller: phoneController,
                      label: 'Phone Number',
                      hint: 'Enter phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 17),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 56,

                      child: ElevatedButton.icon(
                        onPressed: saveContact,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: navy,
                          foregroundColor: Colors.white,
                          elevation: 3,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),

                        icon: const Icon(Icons.add_rounded, size: 24),

                        label: const Text(
                          'ADD EMERGENCY CONTACT',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ---------------- CONTACT LIST TITLE ----------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Emergency Contacts',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF172033),
                          ),
                        ),

                        StreamBuilder<QuerySnapshot>(
                          stream: getContacts(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox();
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),

                              decoration: BoxDecoration(
                                color: navy.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),

                              child: Text(
                                '${snapshot.data!.docs.length}',
                                style: const TextStyle(
                                  color: navy,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ---------------- CONTACTS ----------------
                    StreamBuilder<QuerySnapshot>(
                      stream: getContacts(),

                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return _messageCard(
                            icon: Icons.error_outline_rounded,
                            message: 'Unable to load contacts.',
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(30),
                            child: Center(
                              child: CircularProgressIndicator(color: navy),
                            ),
                          );
                        }

                        final contacts = snapshot.data!.docs;

                        if (contacts.isEmpty) {
                          return _messageCard(
                            icon: Icons.contact_page_outlined,
                            message: 'No emergency contacts added yet.',
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: contacts.length,

                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),

                          itemBuilder: (context, index) {
                            final data =
                                contacts[index].data() as Map<String, dynamic>;

                            return _contactCard(
                              name: data['name'] ?? '',
                              phone: data['phone'] ?? '',
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- INPUT FIELD ----------------

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,

      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF172033),
        fontWeight: FontWeight.w500,
      ),

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: navy),

        filled: true,
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: navy, width: 1.5),
        ),

        labelStyle: TextStyle(color: Colors.grey.shade600),

        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      ),
    );
  }

  // ---------------- CONTACT CARD ----------------

  Widget _contactCard({required String name, required String phone}) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: Colors.grey.shade100),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              color: navy.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(16),
            ),

            child: const Icon(Icons.person_rounded, color: navy, size: 27),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033),
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),

                    const SizedBox(width: 5),

                    Text(
                      phone,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.09),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.check_rounded,
              color: Colors.green,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- EMPTY / ERROR CARD ----------------

  Widget _messageCard({required IconData icon, required String message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.grey.shade400),

          const SizedBox(height: 10),

          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
