// lib/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:case_next/theme/app_theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundColor,
              HSLColor.fromColor(AppTheme.backgroundColor).withLightness(0.95).toColor(),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0), // Increased horizontal padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                // --- MODIFICATION: Larger Logo ---
                Image.asset(
                  'assets/images/scales_of_justice.png',
                  height: 250, // Increased from 150 to 200
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 30),
                Text(
                  'Welcome to CaseNext',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 20),
                // --- MODIFICATION: More Informative Description ---
                Text(
                  'A unified platform designed for Citizens, Lawyers, and Judges. '
                  'Streamline case management, simplify document handling, '
                  'and bring clarity to every stage of the legal process.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.primaryTextColor.withOpacity(0.8),
                        fontSize: 16,
                      ),
                ),
                const Spacer(flex: 3),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: const Text('Get Started'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}