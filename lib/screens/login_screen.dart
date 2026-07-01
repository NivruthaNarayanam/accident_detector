import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> signIn() async {
    try {
      debugPrint("Sign in started");

      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
      debugPrint("Navigating to HomeScreen");
      debugPrint("Login success: ${userCredential.user?.uid}");

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("Login failed: ${e.code} - ${e.message}");
    } catch (e) {
      debugPrint("Unexpected error: $e");
    }
  }

  Future<void> signUp() async {
    try {
      debugPrint("Signup started");

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      debugPrint("Signup success: ${userCredential.user?.uid}");

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("Signup failed: ${e.code} - ${e.message}");
    } catch (e) {
      debugPrint("Unexpected error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accident Detection App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.health_and_safety, size: 100, color: Colors.red),

            const SizedBox(height: 20),

            const Text(
              'Login Screen',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
              ),
              onPressed: signIn,
              child: const Text('LOGIN', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 10),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: signUp,
              child: const Text('REGISTER', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
