import 'package:case_next/screens/file_new_case_screen.dart';
import 'package:flutter/material.dart';
import 'package:case_next/theme/app_theme.dart';
import 'package:case_next/screens/login_screen.dart';
import 'package:case_next/screens/sign_up_screen.dart';
import 'package:case_next/screens/role_selection_screen.dart';
import 'package:case_next/screens/citizen_verification_screen.dart';
import 'package:case_next/screens/lawyer_verification_screen.dart';
import 'package:case_next/screens/judge_details_screen.dart';
import 'package:case_next/screens/citizen_dashboard.dart';
import 'package:case_next/screens/lawyer_dashboard.dart';
import 'package:case_next/screens/judge_dashboard.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'firebase_options.dart';
import 'package:case_next/screens/verify_email_screen.dart'; 
import 'package:case_next/auth/auth_gate.dart';
import 'package:case_next/screens/user_profile_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized(); 
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      home: const AuthGate(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/sign-up': (context) => const SignUpScreen(),
        '/verify-email': (context) => const VerifyEmailScreen(),
        '/role-selection': (context) => const RoleSelectionScreen(),
        '/citizen-verification': (context) => const CitizenVerificationScreen(),
        '/lawyer-verification': (context) => const LawyerVerificationScreen(),
        '/judge-details': (context) => const JudgeDetailsScreen(),
        '/citizen-dashboard': (context) => const CitizenDashboard(),
        '/lawyer-dashboard': (context) => const LawyerDashboard(),
        '/judge-dashboard': (context) => const JudgeDashboard(),
        '/user-profile': (context) => const UserProfileScreen(),
        '/file-new-case': (context) => const FileNewCaseScreen(),
      },
    );
  }
}