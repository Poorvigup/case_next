// lib/main.dart

import 'package:flutter/material.dart';
import 'package:case_next/theme/app_theme.dart';
import 'package:case_next/screens/onboarding_screen.dart';
import 'package:case_next/screens/login_screen.dart';
import 'package:case_next/screens/sign_up_screen.dart';
import 'package:case_next/screens/role_selection_screen.dart';
import 'package:case_next/screens/citizen_verification_screen.dart';
import 'package:case_next/screens/lawyer_verification_screen.dart';
import 'package:case_next/screens/judge_details_screen.dart';
import 'package:case_next/screens/citizen_dashboard.dart';
import 'package:case_next/screens/lawyer_dashboard.dart';
import 'package:case_next/screens/judge_dashboard.dart';

void main() {
  runApp(const CaseNextApp());
}

class CaseNextApp extends StatelessWidget {
  const CaseNextApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CaseNext',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/sign-up': (context) => const SignUpScreen(),
        '/role-selection': (context) => const RoleSelectionScreen(),
        '/citizen-verification': (context) => const CitizenVerificationScreen(),
        '/lawyer-verification': (context) => const LawyerVerificationScreen(),
        '/judge-details': (context) => const JudgeDetailsScreen(),
        '/citizen-dashboard': (context) => const CitizenDashboard(),
        '/lawyer-dashboard': (context) => const LawyerDashboard(),
        '/judge-dashboard': (context) => const JudgeDashboard(),
      },
    );
  }
}