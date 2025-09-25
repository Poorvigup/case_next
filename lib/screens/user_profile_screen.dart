import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:case_next/auth/auth_gate.dart'; // We'll navigate here on sign out

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // State variables to hold the user data
  String? _userEmail;
  String? _userRole;
  bool _isLoading = true; // To show a loading indicator while fetching data

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // This function fetches the current user's data
  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // This should not happen if we are on this screen, but it's a good safety check
      setState(() { _isLoading = false; });
      return;
    }

    // Get the email from Auth
    _userEmail = user.email;

    // Get the role from Firestore
    final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (docSnapshot.exists) {
      _userRole = docSnapshot.data()?['role'];
    }

    // Update the UI
    setState(() {
      _isLoading = false;
    });
  }

  // This function handles the sign-out process
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      
      // After signing out, we want to navigate the user out of the authenticated part of the app.
      // We navigate to the AuthGate and remove all previous routes from the stack.
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthGate()),
          (Route<dynamic> route) => false, // This predicate removes all routes.
        );
      }
    } catch (e) {
      // Show an error if sign-out fails
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign out: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Signed In As:',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _userEmail ?? 'No email found',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your Role:',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _userRole?.toUpperCase() ?? 'No role found',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700, // Make the button red
                      ),
                      onPressed: _signOut,
                      child: const Text('Sign Out'),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}