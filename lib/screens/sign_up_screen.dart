// lib/screens/sign_up_screen.dart

import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // State variable to track password visibility
  bool _isPasswordObscured = true;

  void _performSignUp() {
    // In a real app, you would validate the form before navigating
    Navigator.of(context).pushReplacementNamed('/role-selection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              "Begin Your Journey",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Full Name'),
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Email Address'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            // --- MODIFIED PASSWORD FIELD ---
            TextFormField(
              obscureText: _isPasswordObscured, // Bind to the state variable
              decoration: InputDecoration(
                labelText: 'Password',
                // Add the toggle icon here
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    // Update the state to toggle visibility
                    setState(() {
                      _isPasswordObscured = !_isPasswordObscured;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _performSignUp,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}