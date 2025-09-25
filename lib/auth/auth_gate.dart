// lib/auth/auth_gate.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:case_next/screens/onboarding_screen.dart'; // Your first screen for new users
import 'package:cloud_firestore/cloud_firestore.dart'; // Needed for the redirect logic

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens to the authentication state
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. While waiting for the check, show a loading indicator.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. If the snapshot has data, it means a user IS logged in.
        if (snapshot.hasData) {
          // The user is logged in, now figure out where to send them.
          // We will use a FutureBuilder to get their role from Firestore.
          return RoleBasedRedirect(userId: snapshot.data!.uid);
        }

        // 3. If there's no data, no user is logged in.
        // Send them to the beginning of the onboarding/login flow.
        return const OnboardingScreen();
      },
    );
  }
}

// This new widget will handle the logic of fetching the role and redirecting.
class RoleBasedRedirect extends StatelessWidget {
  final String userId;
  const RoleBasedRedirect({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        // While we wait for the data, show a loading screen
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If there's an error or no data, send to login (safety net)
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          // You could show an error message and then navigate
          // For now, we send to the start of the flow
          return const OnboardingScreen();
        }

        // We have the data, let's find the role
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final userRole = userData['role'];

        // Use addPostFrameCallback to navigate AFTER the widget has finished building
        WidgetsBinding.instance.addPostFrameCallback((_) {
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
              routeName = '/'; // Back to the start if role is unknown
          }
          Navigator.of(context).pushReplacementNamed(routeName);
        });

        // While navigating, just show an empty container or a loading indicator
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}