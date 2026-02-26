import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_controller.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scans = context.watch<AppController>().scans;
    return Scaffold(
      appBar: AppBar(title: const Text('Scan History (Last 100)')),
      body: ListView.builder(
        itemCount: scans.length,
        itemBuilder: (_, i) {
          final s = scans[i];
          final summary = s.resultJson['summary'] as Map<String, dynamic>? ?? {};
          return ListTile(
            title: Text('${s.riceType} • ${summary['milling_grade'] ?? '-'}'),
            subtitle: Text(s.createdAt.toLocal().toString()),
          );
        },
      ),
    );
  }
}
