import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_controller.dart';

class DisclaimerScreen extends StatelessWidget {
  final bool forceShow;
  const DisclaimerScreen({super.key, required this.forceShow});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disclaimer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This tool is intended for indicative, field-level quality assessment and does not replace laboratory analysis or provide food safety certification.',
              style: TextStyle(fontSize: 18),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                await context.read<AppController>().acceptDisclaimer();
                if (context.mounted && forceShow) {
                  Navigator.pushReplacementNamed(context, '/');
                } else if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('I Understand'),
            )
          ],
        ),
      ),
    );
  }
}
