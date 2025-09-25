import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:case_next/utils/dialogs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- NEW: Add Form Key and TextEditingControllers ---
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordObscured = true;

  // --- MODIFIED: The Real Login Logic ---
  Future<void> _performLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Step 1: Sign in the user with Auth
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Check for email verification
      if (userCredential.user == null || !userCredential.user!.emailVerified) {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your email has not been verified. Please check your inbox.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return; // Stop the function here
      }

      // --- NEW: FETCH USER ROLE FROM FIRESTORE ---
      // Step 2: Get the user's document from Firestore
      final uid = userCredential.user!.uid;
      final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!docSnapshot.exists || docSnapshot.data() == null) {
        // This is an edge case: the user exists in Auth but not in Firestore.
        // We should probably sign them out and show an error.
        await FirebaseAuth.instance.signOut();
        throw Exception('User data not found. Please complete the sign-up process.');
      }

      // Step 3: Get the role from the document data
      final userData = docSnapshot.data()!;
      final String userRole = userData['role'];

      // Step 4: Navigate based on the role
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        String routeName;
        switch (userRole) {
          case 'citizen':
            routeName = '/citizen-dashboard';
            break;
          case 'lawyer':
            routeName = '/lawyer-dashboard';
            break;
          case 'judge':
            routeName = '/judge-dashboard';
            break;
          default:
            // If role is unknown, send to login screen
            throw Exception('Unknown user role.');
        }
        Navigator.of(context).pushReplacementNamed(routeName);
      }
      // -------------------------------------------

    } catch (e) {
      // Generic error handling for both Auth and Firestore errors
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is removed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        showExitConfirmationDialog(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sign In'),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          // --- NEW: Wrap the Column in a Form widget ---
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Text(
                  "Access Your Dashboard",
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
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
                        setState(() { _isPasswordObscured = !_isPasswordObscured; });
                      },
                    ),
                  ),
                  validator: (value) { // --- Add validation ---
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: () {}, child: const Text('Forgot Password?')),
                ),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _performLogin, child: const Text('Sign In')),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed('/sign-up'),
                      child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}