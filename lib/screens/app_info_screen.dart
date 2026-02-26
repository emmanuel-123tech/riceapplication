import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../services/app_controller.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    return Scaffold(
      appBar: AppBar(title: const Text('App Info')),
      body: FutureBuilder(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final package = snapshot.data;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(title: const Text('App Version'), subtitle: Text(package?.version ?? '1.0.0')),
              ListTile(title: const Text('Model Version'), subtitle: Text(app.modelVersion)),
              ListTile(
                title: const Text('Model Weights On Device'),
                subtitle: Text(app.weightsAvailable ? 'Available' : 'Missing'),
              ),
              if (!app.weightsAvailable)
                const Text(
                  'Model weights missing. Copy rice_model.onnx.data into assets/models/ and rebuild.',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          );
        },
      ),
    );
  }
}
