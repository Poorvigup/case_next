// lib/screens/citizen_verification_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CitizenVerificationScreen extends StatefulWidget {
  const CitizenVerificationScreen({super.key});

  @override
  State<CitizenVerificationScreen> createState() => _CitizenVerificationScreenState();
}

class _CitizenVerificationScreenState extends State<CitizenVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aadharController = TextEditingController();

  Future<void> _finishVerification() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Get the current user's UID
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No user logged in!");
      }
      final uid = user.uid;

      // 2. Prepare the data
      final userData = {
        'role': 'citizen', // Set the role
        'email': user.email, // Save the email
        'aadharNumber': _aadharController.text.trim(),
      };

      // 3. Save the data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set(userData);

      // 4. Navigate to the dashboard
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamedAndRemoveUntil('/citizen-dashboard', (route) => false);
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save details: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _aadharController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Citizen Verification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text("Verify Your Identity", style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text("Please provide your Aadhar number to ensure the authenticity of your profile.", style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 40),
              TextFormField(
                controller: _aadharController,
                decoration: const InputDecoration(labelText: 'Aadhar Card Number', counterText: ""),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 12,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Aadhar number is required';
                  if (value.length != 12) return 'Aadhar number must be 12 digits';
                  return null;
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(onPressed: _finishVerification, child: const Text('Verify & Proceed')),
            ],
          ),
        ),
      ),
    );
  }
}