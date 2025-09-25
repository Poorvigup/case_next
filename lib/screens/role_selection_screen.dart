// lib/screens/role_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:case_next/models/user_model.dart';
import 'package:case_next/theme/app_theme.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  /// Navigates to the correct dashboard, clearing the setup history.
  /// This is used for Citizen and Lawyer roles.
  void _navigateToDashboard(BuildContext context, UserRole role) {
    String routeName;
    switch (role) {
      case UserRole.citizen:
        routeName = '/citizen-dashboard';
        break;
      case UserRole.lawyer:
        routeName = '/lawyer-dashboard';
        break;
      case UserRole.judge:
        // This case is now handled by the judge details screen flow,
        // but it's kept here for completeness.
        routeName = '/judge-dashboard';
        break;
    }
    // We replace the entire navigation stack up to this point
    // so the user cannot go back to role selection or sign up.
    Navigator.of(context).pushNamedAndRemoveUntil(routeName, (route) => false);
  }

  /// Shows a confirmation dialog with role-specific features.
  void _showRoleConfirmationDialog(BuildContext context, UserRole role, String roleName, IconData icon) {
    // Define features for each role
    final List<String> features;
    switch (role) {
      case UserRole.citizen:
        features = [
          "File new cases with ease.",
          "Track your case status and hearing dates.",
          "Receive important notifications and updates.",
          "Securely upload and manage documents.",
        ];
        break;
      case UserRole.lawyer:
        features = [
          "Securely upload case documents and details.",
          "Let our AI automatically organize and prioritize your cases.",
          "View a clear, prioritized list of all your active cases.",
          "Focus on what matters most with intelligent case management.",
        ];
        break;
      case UserRole.judge:
        features = [
          "Access an AI-prioritized queue of cases.",
          "Review case files and evidence digitally.",
          "Efficiently schedule hearings and issue orders.",
          "View analytics on courtroom efficiency.",
        ];
        break;
    }

    showDialog(
      context: context,
      barrierDismissible: false, // User must make a choice
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 32, // Larger icon
              ),
              const SizedBox(width: 12),
              // More prominent title text
              Text(
                roleName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You will have access to the following features:",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...features.map((feature) => _FeatureListItem(text: feature)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
              },
            ),
            ElevatedButton(
              onPressed: () {
                // First, dismiss the dialog.
                Navigator.of(dialogContext).pop();
                
                // **UPDATED NAVIGATION LOGIC**
                switch (role) {
                  case UserRole.citizen:
                    Navigator.of(context).pushNamed('/citizen-verification');
                    break;
                  case UserRole.lawyer:
                    Navigator.of(context).pushNamed('/lawyer-verification');
                    break;
                  case UserRole.judge:
                    Navigator.of(context).pushNamed('/judge-details');
                    break;
                }
              },
              child: Text('Continue as $roleName'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Role'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _RoleCard(
                  role: 'Citizen',
                  icon: Icons.person_outline,
                  onTap: () => _showRoleConfirmationDialog(
                    context,
                    UserRole.citizen,
                    'Citizen',
                    Icons.person_outline,
                  ),
                ),
                const SizedBox(height: 24),
                _RoleCard(
                  role: 'Lawyer',
                  icon: Icons.gavel_rounded,
                  onTap: () => _showRoleConfirmationDialog(
                    context,
                    UserRole.lawyer,
                    'Lawyer',
                    Icons.gavel_rounded,
                  ),
                ),
                const SizedBox(height: 24),
                _RoleCard(
                  role: 'Judge',
                  icon: Icons.account_balance_rounded,
                  onTap: () => _showRoleConfirmationDialog(
                    context,
                    UserRole.judge,
                    'Judge',
                    Icons.account_balance_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A helper widget to display a feature in the confirmation dialog.
class _FeatureListItem extends StatelessWidget {
  final String text;
  const _FeatureListItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppTheme.accentColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

/// The main tappable card widget for role selection.
class _RoleCard extends StatelessWidget {
  final String role;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.0),
          splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
          highlightColor: Theme.of(context).primaryColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 50,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 20),
                Text(
                  role,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}