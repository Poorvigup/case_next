// lib/screens/lawyer_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:case_next/utils/dialogs.dart';

class LawyerDashboard extends StatefulWidget {
  const LawyerDashboard({super.key});
  @override
  State<LawyerDashboard> createState() => _LawyerDashboardState();
}

class _LawyerDashboardState extends State<LawyerDashboard> {
  final List<Map<String, dynamic>> _cases = [];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        showExitConfirmationDialog(context);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Case Dashboard'), automaticallyImplyLeading: false),
        body: _cases.isEmpty
            ? const _EmptyStateWidget(
                imagePath: 'assets/images/empty_lawyer.png',
                title: 'Your Dashboard is Ready',
                message: 'Use the Speed Dial to add your first case, either individually or through a bulk upload.',
              )
            : Column(
                children: [
                  _buildSummaryCards(context, _cases.where((c) => c['isUrgent']).length, _cases.length),
                  const Divider(height: 1),
                  Padding(padding: const EdgeInsets.all(16.0), child: Text('All Cases', style: Theme.of(context).textTheme.titleLarge)),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80.0),
                      itemCount: _cases.length,
                      itemBuilder: (context, index) {
                        final caseData = _cases[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(caseData['isUrgent'] ? Icons.priority_high_rounded : Icons.work_history_outlined, color: caseData['isUrgent'] ? Colors.red.shade700 : Theme.of(context).primaryColor),
                            title: Text(caseData['title']),
                            subtitle: Text(caseData['isUrgent'] ? 'Urgent Action Required' : 'Standard Priority'),
                            onTap: () {},
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
        floatingActionButton: SpeedDial(
          icon: Icons.add,
          activeIcon: Icons.close,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          children: [
            SpeedDialChild(child: const Icon(Icons.note_add), label: 'Add Single Case', onTap: () {}),
            SpeedDialChild(child: const Icon(Icons.upload_file_rounded), label: 'Bulk Upload Cases', onTap: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, int urgentCount, int totalCount) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(child: Card(color: Colors.red.shade50, child: Padding(padding: const EdgeInsets.all(16.0), child: Column(children: [Text('$urgentCount', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.red.shade800)), const SizedBox(height: 4), Text('Urgent Cases', style: Theme.of(context).textTheme.bodyLarge)])))),
          Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16.0), child: Column(children: [Text('$totalCount', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).primaryColor)), const SizedBox(height: 4), Text('Total Cases', style: Theme.of(context).textTheme.bodyLarge)])))),
        ],
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