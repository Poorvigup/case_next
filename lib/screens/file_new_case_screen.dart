// lib/screens/file_new_case_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class FileNewCaseScreen extends StatefulWidget {
  const FileNewCaseScreen({super.key});

  @override
  State<FileNewCaseScreen> createState() => _FileNewCaseScreenState();
}

class _FileNewCaseScreenState extends State<FileNewCaseScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- NEW: Controllers and State Variables for all form fields ---
  final _titleController = TextEditingController();
  final _partiesController = TextEditingController();
  final _summaryController = TextEditingController();
  final _advocatesController = TextEditingController();
  final _sectionsController = TextEditingController();

  String? _selectedCourt;
  String? _selectedCaseType;
  String? _selectedUrgency;
  String? _selectedPastHistory;
  String? _selectedImpact;
  String? _selectedMediaCoverage;
  final List<String> _courtOptions = ['Supreme Court', 'High Court', 'District Court'];
  final List<String> _caseTypeOptions = ['Civil', 'Criminal', 'Family', 'PIL'];
  final List<String> _urgencyOptions = ['Emergency', 'High-profile', 'Regular'];
  final List<String> _yesNoOptions = ['Yes', 'No'];
  final List<String> _impactOptions = ['High', 'Medium', 'Low'];

   Interpreter? _interpreter;
  String? _predictedPriority;

  @override
  void initState() {
    super.initState();
    _loadModel(); // Load the model when the screen is first created
  }

  // Function to load the TFLite model from assets
  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/ml/case_priority_model.tflite');
      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  // --- THIS IS THE CRITICAL PREPROCESSING FUNCTION ---
  // It converts the user's text selections into a list of numbers for the model.
  // The order and encoding MUST MATCH how your model was trained.
  List<double> _preprocessInput() {
    // Example encoding - YOU MUST ADJUST THIS TO MATCH YOUR MODEL'S TRAINING
    double court = _selectedCourt == 'Supreme Court' ? 2.0 : (_selectedCourt == 'High Court' ? 1.0 : 0.0);
    double caseType = _selectedCaseType == 'PIL' ? 3.0 : (_selectedCaseType == 'Family' ? 2.0 : (_selectedCaseType == 'Criminal' ? 1.0 : 0.0));
    double urgency = _selectedUrgency == 'Emergency' ? 2.0 : (_selectedUrgency == 'High-profile' ? 1.0 : 0.0);
    double pastHistory = _selectedPastHistory == 'Yes' ? 1.0 : 0.0;
    double impact = _selectedImpact == 'High' ? 2.0 : (_selectedImpact == 'Medium' ? 1.0 : 0.0);
    double mediaCoverage = _selectedMediaCoverage == 'Yes' ? 1.0 : 0.0;

    // This must return a list of doubles in the exact order your model expects.
    return [court, caseType, urgency, pastHistory, impact, mediaCoverage];
  }

  // Function to run the model and get the prediction
  String? _runInference() {
    if (_interpreter == null) {
      print('Interpreter not initialized');
      throw Exception('Prediction model is not available.');
    }

    double court = _selectedCourt == 'Supreme Court' ? 2.0 : (_selectedCourt == 'High Court' ? 1.0 : 0.0);
    double caseType = _selectedCaseType == 'PIL' ? 3.0 : (_selectedCaseType == 'Family' ? 2.0 : (_selectedCaseType == 'Criminal' ? 1.0 : 0.0));
    double urgency = _selectedUrgency == 'Emergency' ? 2.0 : (_selectedUrgency == 'High-profile' ? 1.0 : 0.0);
    double pastHistory = _selectedPastHistory == 'Yes' ? 1.0 : 0.0;
    double impact = _selectedImpact == 'High' ? 2.0 : (_selectedImpact == 'Medium' ? 1.0 : 0.0);
    double mediaCoverage = _selectedMediaCoverage == 'Yes' ? 1.0 : 0.0;
    final input = [court, caseType, urgency, pastHistory, impact, mediaCoverage];

    var modelInput = [input];
    var modelOutput = List.generate(1, (index) => List.filled(3, 0.0));

    _interpreter!.run(modelInput, modelOutput);
    // Post-process the output
    List<double> probabilities = modelOutput[0];
    int maxIndex = 0;
    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > probabilities[maxIndex]) {
        maxIndex = i;
      }
    }

    // Convert the index back to a human-readable label
    // This order MUST match the output encoding of your model
    const labels = ['Low', 'Medium', 'High']; 
    // Create the final variable to hold the result
    final String prediction = labels[maxIndex];

    // Now use this new variable
    print('Model Input: $input');
    print('Model Output (Probabilities): $probabilities');
    print('Predicted Priority: $prediction');

    // Return the variable
    return prediction;
  }

  // --- MODIFIED: The submit function now includes all new data ---
Future<void> _submitCase() async {
    // 1. Validate the form's text fields and dropdowns
    if (!_formKey.currentState!.validate()) {
      return; // If any validator fails, stop here.
    }
    
    // 2. Show a loading dialog so the user knows something is happening
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 3. --- CRITICAL VALIDATION STEP ---
      // Manually check that all required data for the model is present.
      // This will give us a clear error instead of the TFLite one.
      final modelInputs = {
        'Court Name': _selectedCourt,
        'Case Type': _selectedCaseType,
        'Urgency': _selectedUrgency,
        'Past History': _selectedPastHistory,
        'Estimated Impact': _selectedImpact,
        'Media Coverage': _selectedMediaCoverage,
      };

      for (final entry in modelInputs.entries) {
        if (entry.value == null) {
          throw Exception('${entry.key} is missing. Please select a value.');
        }
      }
      // --- END OF VALIDATION ---

      // 4. If validation passes, run the model
      final predictedPriority = _runInference();
      
      if (predictedPriority == null) {
        throw Exception('Prediction failed after running the model.');
      }

      // 5. Get user and prepare data for Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User is not logged in.");

      final caseData = {
        'filedByUid': user.uid, 'filedByEmail': user.email, 'filedAt': FieldValue.serverTimestamp(), 'status': 'Submitted',
        'Case_Summary': _summaryController.text.trim(), 'Court_Name': _selectedCourt, 'Case_Type': _selectedCaseType,
        'Parties_Involved': _partiesController.text.trim(), 'Urgency_Tag': _selectedUrgency, 'Advocate_Names': _advocatesController.text.trim(),
        'Legal_Sections': _sectionsController.text.trim(), 'Past_History': _selectedPastHistory, 'Estimated_Impact': _selectedImpact,
        'Media_Coverage': _selectedMediaCoverage, 'title': _titleController.text.trim(),
        'Priority_Label': predictedPriority,
      };
      
      // 6. Save to Firestore
      await FirebaseFirestore.instance.collection('cases').add(caseData);

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Case submitted! Predicted Priority: $predictedPriority')),
        );
        Navigator.of(context).pop(); // Go back to dashboard
      }
    } catch (e) {
      // 7. This will now catch our clear, custom error messages
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit case: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _partiesController.dispose();
    _summaryController.dispose();
    _advocatesController.dispose();
    _sectionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File a New Case')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- THIS IS THE NEW, EXPANDED FORM ---
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Case Title / Subject'),
                validator: (v) => v == null || v.isEmpty ? 'Please enter a title.' : null,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedCourt,
                decoration: const InputDecoration(labelText: 'Court Name'),
                items: _courtOptions.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                onChanged: (v) => setState(() => _selectedCourt = v),
                validator: (v) => v == null ? 'Please select a court.' : null,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedCaseType,
                decoration: const InputDecoration(labelText: 'Case Type'),
                items: _caseTypeOptions.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                onChanged: (v) => setState(() => _selectedCaseType = v),
                validator: (v) => v == null ? 'Please select a case type.' : null,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _partiesController,
                decoration: const InputDecoration(labelText: 'Parties Involved (e.g., Your Name vs. Other Party)'),
                validator: (v) => v == null || v.isEmpty ? 'Please enter the parties involved.' : null,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedUrgency,
                decoration: const InputDecoration(labelText: 'Urgency'),
                items: _urgencyOptions.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                onChanged: (v) => setState(() => _selectedUrgency = v),
                validator: (v) => v == null ? 'Please select the urgency.' : null,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedImpact,
                decoration: const InputDecoration(labelText: 'Estimated Impact'),
                items: _impactOptions.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                onChanged: (v) => setState(() => _selectedImpact = v),
                validator: (v) => v == null ? 'Please select the estimated impact.' : null,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedPastHistory,
                decoration: const InputDecoration(labelText: 'Is there a past history of similar cases?'),
                items: _yesNoOptions.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                onChanged: (v) => setState(() => _selectedPastHistory = v),
                validator: (v) => v == null ? 'Please select an option.' : null,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedMediaCoverage,
                decoration: const InputDecoration(labelText: 'Is there existing media coverage?'),
                items: _yesNoOptions.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                onChanged: (v) => setState(() => _selectedMediaCoverage = v),
                validator: (v) => v == null ? 'Please select an option.' : null,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _advocatesController,
                decoration: const InputDecoration(labelText: 'Advocate Names (if any)'),
                // No validator, this is optional
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _sectionsController,
                decoration: const InputDecoration(labelText: 'Legal Sections (if known)'),
                // No validator, this is optional
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _summaryController,
                decoration: const InputDecoration(
                  labelText: 'Case Summary',
                  hintText: 'Provide a detailed description of the incident or issue.',
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                validator: (v) => v == null || v.isEmpty ? 'Please provide a summary.' : null,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _submitCase,
                child: const Text('Submit Case'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}