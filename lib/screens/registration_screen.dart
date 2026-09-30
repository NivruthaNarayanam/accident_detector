import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final addressController = TextEditingController();
  final medicalController = TextEditingController();
  final allergiesController = TextEditingController();

  String? selectedGender;
  String? selectedBloodGroup;

  bool isPasswordVisible = false;
  bool isLoading = false;

  static const Color navy = Color(0xFF123B78);
  static const Color red = Color(0xFFE53935);
  static const Color green = Color(0xFF22A06B);
  static const Color background = Color(0xFFF7F9FC);

  // ============================================================
  // REGISTER USER
  // ============================================================

  Future<void> registerUser() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        dobController.text.trim().isEmpty ||
        selectedGender == null ||
        selectedBloodGroup == null ||
        addressController.text.trim().isEmpty) {
      _showMessage('Please fill all required fields.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'dob': dobController.text.trim(),
        'gender': selectedGender,
        'bloodGroup': selectedBloodGroup,
        'address': addressController.text.trim(),
        'medicalConditions': medicalController.text.trim().isEmpty
            ? 'None'
            : medicalController.text.trim(),
        'allergies': allergiesController.text.trim().isEmpty
            ? 'None'
            : allergiesController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Registration successful: $uid');

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Registration failed: ${e.code}');

      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'weak-password':
          message = 'Please choose a stronger password.';
          break;

        case 'operation-not-allowed':
          message = 'Email registration is currently unavailable.';
          break;

        default:
          message = e.message ?? 'Registration failed.';
      }

      if (mounted) {
        _showMessage(message);
      }
    } catch (e) {
      debugPrint('Registration error: $e');

      if (mounted) {
        _showMessage('Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // DATE OF BIRTH
  // ============================================================

  Future<void> selectDateOfBirth() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: const ColorScheme.light(primary: navy)),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        dobController.text =
            '${pickedDate.day.toString().padLeft(2, '0')}/'
            '${pickedDate.month.toString().padLeft(2, '0')}/'
            '${pickedDate.year}';
      });
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // ============================================================
  // FIELD DECORATION
  // ============================================================

  InputDecoration fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: navy),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: navy, width: 1.5),
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: navy.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: navy, size: 21),
        ),
        const SizedBox(width: 11),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: navy,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    dobController.dispose();
    addressController.dispose();
    medicalController.dispose();
    allergiesController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

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
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
        child: Column(
          children: [
            // --------------------------------------------------
            // HEADER
            // --------------------------------------------------
            Container(
              width: 82,
              height: 82,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: navy.withValues(alpha: 0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Image.asset('assets/app_icon.png', fit: BoxFit.contain),
            ),

            const SizedBox(height: 16),

            const Text(
              'Create Account',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Set up your emergency profile',
              style: TextStyle(
                fontSize: 14,
                color: red,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your information helps QuickAlert '
              'provide the right details during an emergency.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 25),

            // --------------------------------------------------
            // PERSONAL INFORMATION
            // --------------------------------------------------
            buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSectionHeader(
                    Icons.person_outline_rounded,
                    'PERSONAL INFORMATION',
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: fieldDecoration(
                      hint: 'Full Name *',
                      icon: Icons.person_outline,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: fieldDecoration(
                      hint: 'Email *',
                      icon: Icons.email_outlined,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: fieldDecoration(
                      hint: 'Password *',
                      icon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: fieldDecoration(
                      hint: 'Phone Number *',
                      icon: Icons.phone_outlined,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: dobController,
                    readOnly: true,
                    onTap: selectDateOfBirth,
                    decoration:
                        fieldDecoration(
                          hint: 'Date of Birth *',
                          icon: Icons.calendar_today_outlined,
                        ).copyWith(
                          suffixIcon: const Icon(
                            Icons.arrow_drop_down_rounded,
                            color: navy,
                          ),
                        ),
                  ),

                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    initialValue: selectedGender,
                    decoration: fieldDecoration(
                      hint: 'Gender *',
                      icon: Icons.wc_outlined,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // --------------------------------------------------
            // MEDICAL INFORMATION
            // --------------------------------------------------
            buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSectionHeader(
                    Icons.medical_information_outlined,
                    'MEDICAL INFORMATION',
                  ),

                  const SizedBox(height: 18),

                  DropdownButtonFormField<String>(
                    initialValue: selectedBloodGroup,
                    decoration: fieldDecoration(
                      hint: 'Blood Group *',
                      icon: Icons.bloodtype_outlined,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'A+', child: Text('A+')),
                      DropdownMenuItem(value: 'A-', child: Text('A-')),
                      DropdownMenuItem(value: 'B+', child: Text('B+')),
                      DropdownMenuItem(value: 'B-', child: Text('B-')),
                      DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                      DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                      DropdownMenuItem(value: 'O+', child: Text('O+')),
                      DropdownMenuItem(value: 'O-', child: Text('O-')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedBloodGroup = value;
                      });
                    },
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: medicalController,
                    maxLines: 2,
                    decoration: fieldDecoration(
                      hint: 'Medical Conditions (Optional)',
                      icon: Icons.healing_outlined,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: allergiesController,
                    maxLines: 2,
                    decoration: fieldDecoration(
                      hint: 'Allergies (Optional)',
                      icon: Icons.warning_amber_outlined,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // --------------------------------------------------
            // ADDRESS
            // --------------------------------------------------
            buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSectionHeader(Icons.location_on_outlined, 'ADDRESS'),

                  const SizedBox(height: 18),

                  TextField(
                    controller: addressController,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: fieldDecoration(
                      hint: 'Your Address *',
                      icon: Icons.home_outlined,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // --------------------------------------------------
            // CREATE ACCOUNT
            // --------------------------------------------------
            SizedBox(
              width: double.infinity,
              height: 53,
              child: ElevatedButton(
                onPressed: isLoading ? null : registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: navy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'CREATE ACCOUNT',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.7,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'By creating an account, your emergency '
              'profile can be used to provide relevant '
              'information during an alert.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.black45,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Detect • Alert • Save',
              style: TextStyle(
                fontSize: 11,
                color: Colors.black45,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
