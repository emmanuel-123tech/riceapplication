import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    return Scaffold(
      appBar: AppBar(title: const Text('AfricaRice QA Home')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!app.weightsAvailable)
            Card(
              color: Colors.orange.shade100,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Model weights missing. Copy rice_model.onnx.data into assets/models/ and rebuild.'),
              ),
            ),
          ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/capture'), child: const Text('Start Scan')),
          ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/history'), child: const Text('Scan History')),
          ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/export'), child: const Text('Export/Share Results')),
          ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/info'), child: const Text('App Info / Model Version')),
          TextButton(onPressed: () => Navigator.pushNamed(context, '/disclaimer'), child: const Text('View Disclaimer')),
        ],
      ),
    );
  }
}
