// lib/screens/sign_up_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // --- NEW: Add a Form Key and TextEditingControllers ---
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // We don't need a controller for name for auth, but you would for saving to a database.

  bool _isPasswordObscured = true;

  // --- MODIFIED: The Sign Up Logic ---
  Future<void> _performSignUp() async {
    // 1. Validate the form
    if (!_formKey.currentState!.validate()) {
      return; // If the form is not valid, do nothing.
    }

    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 2. Use Firebase Auth to create a new user
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword( // A. Store the result
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // --- NEW: SEND THE VERIFICATION EMAIL ---
      await userCredential.user?.sendEmailVerification();
      // -----------------------------------------

      // 3. If successful, dismiss the loading dialog and navigate
      if (mounted) {
        // Optional: Show a message telling the user to check their email
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A verification email has been sent. Please check your inbox.')),
        );
        Navigator.of(context).pop(); // Close the loading dialog
        Navigator.of(context).pushReplacementNamed('/verify-email');
      }

    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase errors
      Navigator.of(context).pop(); // Close the loading dialog
      String errorMessage = 'An error occurred. Please try again.';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for that email.';
      }
      
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } catch (e) {
      // Handle any other errors
      Navigator.of(context).pop(); // Close the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    // Clean up controllers
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      // --- NEW: Wrap the Column in a Form widget ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
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
                // You can add a validator here if you want
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController, // --- Attach controller ---
                decoration: const InputDecoration(labelText: 'Email Address'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) { // --- Add validation ---
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController, // --- Attach controller ---
                obscureText: _isPasswordObscured,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordObscured = !_isPasswordObscured;
                      });
                    },
                  ),
                ),
                validator: (value) { // --- Add validation ---
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _performSignUp,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}