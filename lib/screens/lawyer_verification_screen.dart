// lib/screens/lawyer_verification_screen.dart

import 'package:flutter/material.dart';

class LawyerVerificationScreen extends StatefulWidget {
  const LawyerVerificationScreen({super.key});

  @override
  State<LawyerVerificationScreen> createState() => _LawyerVerificationScreenState();
}

class _LawyerVerificationScreenState extends State<LawyerVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedStateBar;
  
  // A simplified list. In a real app, this would be the official list of state bar councils.
  final List<String> _stateBarCouncils = [
    'Andhra Pradesh', 'Assam, Nagaland, etc.', 'Bihar', 'Chhattisgarh', 'Delhi', 
    'Gujarat', 'Himachal Pradesh', 'Jammu & Kashmir', 'Jharkhand', 'Karnataka', 
    'Kerala', 'Madhya Pradesh', 'Maharashtra & Goa', 'Orissa', 'Punjab & Haryana', 
    'Rajasthan', 'Tamil Nadu & Puducherry', 'Telangana', 'Tripura', 'Uttar Pradesh', 
    'Uttarakhand', 'West Bengal'
  ];

  void _finishVerification() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print('Lawyer Verification Successful');
      Navigator.of(context).pushNamedAndRemoveUntil('/lawyer-dashboard', (route) => false);
    }
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