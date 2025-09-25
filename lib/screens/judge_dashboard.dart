// lib/screens/judge_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:case_next/theme/app_theme.dart';
import 'package:case_next/utils/dialogs.dart';

class JudgeDashboard extends StatefulWidget {
  const JudgeDashboard({super.key});
  @override
  State<JudgeDashboard> createState() => _JudgeDashboardState();
}

class _JudgeDashboardState extends State<JudgeDashboard> {
  final List<Map<String, dynamic>> _priorityCases = [];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        showExitConfirmationDialog(context);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Court Priority Queue'), 
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.of(context).pushNamed('/user-profile');
          },
        ),
      ],),
        body: _priorityCases.isEmpty
            ? const _EmptyStateWidget(
                imagePath: 'assets/images/empty_judge.png',
                title: 'The Queue is Clear',
                message: 'There are currently no cases in your priority queue. New cases will appear here automatically.',
              )
            : ListView.builder(
                padding: const EdgeInsets.only(top: 8.0, bottom: 80.0),
                itemCount: _priorityCases.length,
                itemBuilder: (context, index) {
                  final caseData = _priorityCases[index];
                  return Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PriorityScoreIndicator(score: caseData['score']),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(caseData['title'], style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text('Reason for Priority:', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                                Text(caseData['reason'], style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: SpeedDial(
          icon: Icons.edit_calendar,
          activeIcon: Icons.close,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          children: [
            SpeedDialChild(child: const Icon(Icons.schedule), label: 'Schedule Hearing', onTap: () {}),
            SpeedDialChild(child: const Icon(Icons.receipt_long), label: 'Issue Order', onTap: () {}),
          ],
        ),
      ),
    );
  }
}

// --- MODIFIED WIDGET ---
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

class _PriorityScoreIndicator extends StatelessWidget {
  final double score;
  const _PriorityScoreIndicator({required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('AI Score', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.primaryColor, width: 2), color: Colors.white),
          child: Text(score.toString(), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }
}