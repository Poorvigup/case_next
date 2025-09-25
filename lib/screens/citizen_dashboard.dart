// lib/screens/citizen_dashboard.dart

import 'package:flutter/material.dart';
import 'package:case_next/utils/dialogs.dart';

class CitizenDashboard extends StatefulWidget {
  const CitizenDashboard({super.key});
  @override
  State<CitizenDashboard> createState() => _CitizenDashboardState();
}

class _CitizenDashboardState extends State<CitizenDashboard> {
  final List<Map<String, String>> _cases = [];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        showExitConfirmationDialog(context);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('My Cases'), 
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.of(context).pushNamed('/user-profile');
          },
        ),
      ],),
        body: _cases.isEmpty
            ? const _EmptyStateWidget(
                imagePath: 'assets/images/empty_citizen.png',
                title: 'No Cases Yet',
                message: 'When you file a new case, it will appear here. Tap the button below to get started.',
              )
            : ListView.builder(
                padding: const EdgeInsets.only(top: 8.0, bottom: 80.0),
                itemCount: _cases.length,
                itemBuilder: (context, index) {
                  final caseData = _cases[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.folder_copy_outlined, color: Theme.of(context).primaryColor, size: 40),
                      title: Text('Next Hearing: ${caseData['date']}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text('Case Status: ${caseData['status']}', style: Theme.of(context).textTheme.bodyMedium),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {},
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: const Text('File a New Case'),
          icon: const Icon(Icons.upload_file),
        ),
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final String message;
  const _EmptyStateWidget({required this.imagePath, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 180,
              // --- FIX: The `color` property has been removed ---
            ),
            const SizedBox(height: 24),
            Text(title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}