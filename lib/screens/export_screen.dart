import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_controller.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  String status = '';

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Export / Share')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final f = await app.exportCsv();
                setState(() => status = 'CSV exported to ${f.path}');
              },
              child: const Text('Export CSV'),
            ),
            ElevatedButton(
              onPressed: () async {
                await app.shareCsv();
                setState(() => status = 'Share opened');
              },
              child: const Text('Share CSV'),
            ),
            const SizedBox(height: 12),
            Text(status),
          ],
        ),
      ),
    );
  }
}
