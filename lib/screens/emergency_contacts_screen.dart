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
        const SnackBar(
          content: Text("Please enter both name and phone number"),
        ),
      );
      return;
    }
    debugPrint("SAVE BUTTON PRESSED");

    try {
      final user = FirebaseAuth.instance.currentUser;

      debugPrint("Current user: ${user?.uid}");

      if (user == null) {
        debugPrint("USER IS NULL");
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Contact Saved')));

      nameController.clear();
      phoneController.clear();
    } catch (e) {
      debugPrint("Error saving contact: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Emergency Contacts")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Contact Name"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Phone Number"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                debugPrint("BUTTON CLICKED");
                saveContact();
              },
              child: const Text("Save Contact"),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getContacts(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text("Something went wrong");
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final contacts = snapshot.data!.docs;

                  if (contacts.isEmpty) {
                    return const Center(child: Text("No contacts added yet"));
                  }

                  return ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final data =
                          contacts[index].data() as Map<String, dynamic>;

                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(data['name'] ?? ''),
                          subtitle: Text(data['phone'] ?? ''),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
