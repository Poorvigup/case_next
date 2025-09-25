// lib/screens/verify_email_screen.dart

import 'dart:async'; // Required for the Timer
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isEmailVerified = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // A user must exist when we get to this screen
    // so FirebaseAuth.instance.currentUser should not be null.
    _isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    // If the user's email is NOT verified, we start a timer.
    if (!_isEmailVerified) {
      // The timer will run the checkEmailVerified function every 3 seconds.
      _timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  // This function is crucial. It's called by the timer.
  Future<void> checkEmailVerified() async {
    // 1. We have to reload the user from Firebase to get the latest data.
    await FirebaseAuth.instance.currentUser!.reload();

    // 2. We update the state of our screen with the new verification status.
    setState(() {
      _isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    // 3. If the email is now verified...
    if (_isEmailVerified) {
      // ...we cancel the timer so it doesn't run forever.
      _timer?.cancel();
      
      // And navigate to the next screen in the onboarding process.
      Navigator.of(context).pushReplacementNamed('/role-selection');
    }
  }

  // It's very important to cancel the timer when the screen is disposed.
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'A verification email has been sent to:',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                // Display the user's email
                FirebaseAuth.instance.currentUser?.email ?? 'your email',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text(
                'Please click the link in the email to continue. This screen will update automatically once you are verified.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 16),
              const Center(child: Text('Waiting for verification...')),
            ],
          ),
        ),
      ),
    );
  }
}