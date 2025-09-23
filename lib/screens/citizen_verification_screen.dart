// lib/screens/citizen_verification_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CitizenVerificationScreen extends StatefulWidget {
  const CitizenVerificationScreen({super.key});

  @override
  State<CitizenVerificationScreen> createState() => _CitizenVerificationScreenState();
}

class _CitizenVerificationScreenState extends State<CitizenVerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  void _finishVerification() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print('Aadhar Verification Successful');
      Navigator.of(context).pushNamedAndRemoveUntil('/citizen-dashboard', (route) => false);
    }
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