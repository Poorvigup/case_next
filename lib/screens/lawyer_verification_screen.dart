// lib/screens/lawyer_verification_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LawyerVerificationScreen extends StatefulWidget {
  const LawyerVerificationScreen({super.key});

  @override
  State<LawyerVerificationScreen> createState() => _LawyerVerificationScreenState();
}

class _LawyerVerificationScreenState extends State<LawyerVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _regNumberController = TextEditingController(); 
  String? _selectedStateBar;
  
  // A simplified list. In a real app, this would be the official list of state bar councils.
  final List<String> _stateBarCouncils = [
    'Andhra Pradesh', 'Assam, Nagaland, etc.', 'Bihar', 'Chhattisgarh', 'Delhi', 
    'Gujarat', 'Himachal Pradesh', 'Jammu & Kashmir', 'Jharkhand', 'Karnataka', 
    'Kerala', 'Madhya Pradesh', 'Maharashtra & Goa', 'Orissa', 'Punjab & Haryana', 
    'Rajasthan', 'Tamil Nadu & Puducherry', 'Telangana', 'Tripura', 'Uttar Pradesh', 
    'Uttarakhand', 'West Bengal'
  ];

  Future<void> _finishVerification() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      // 1. Get the current user's unique ID (UID) from Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No user logged in!"); // This should not happen
      }
      final uid = user.uid;

      // 2. Prepare the data to be saved
      final userData = {
        'role': 'lawyer', // Set the role
        'email': user.email, // Save the email for reference
        'stateBarCouncil': _selectedStateBar,
        'barRegistrationNumber': _regNumberController.text.trim(),
      };

      // 3. Get a reference to the Firestore document and save the data
      // We are creating a document inside the 'users' collection,
      // and the document's ID will be the user's UID.
      await FirebaseFirestore.instance.collection('users').doc(uid).set(userData);

      // 4. If successful, navigate to the dashboard
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        Navigator.of(context).pushNamedAndRemoveUntil('/lawyer-dashboard', (route) => false);
      }

    } catch (e) {
      // Handle errors (e.g., show a snackbar)
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save details: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _regNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lawyer Verification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                "Provide Your Credentials",
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              DropdownButtonFormField<String>(
                value: _selectedStateBar,
                decoration: const InputDecoration(labelText: 'State Bar Council'),
                items: _stateBarCouncils.map((bar) => DropdownMenuItem<String>(value: bar, child: Text(bar))).toList(),
                onChanged: (newValue) => setState(() => _selectedStateBar = newValue),
                validator: (value) => value == null ? 'Please select your Bar Council' : null,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _regNumberController,
                decoration: const InputDecoration(labelText: 'Bar Council Registration No.'),
                validator: (value) => value == null || value.isEmpty ? 'Registration number is required' : null,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _finishVerification,
                child: const Text('Verify & Proceed'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}