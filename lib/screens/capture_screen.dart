import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/app_controller.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  String riceType = 'Paddy';
  final picker = ImagePicker();
  final images = <String>[];
  String? selected;
  bool running = false;

  Future<void> _takeImage() async {
    final x = await picker.pickImage(source: ImageSource.camera, imageQuality: 95);
    if (x != null) {
      setState(() {
        if (images.length < 2) images.add(x.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Capture')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: riceType,
              items: const ['Paddy', 'White', 'Brown']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => riceType = v ?? 'Paddy'),
              decoration: const InputDecoration(labelText: 'Rice type *'),
            ),
            Card(
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Capture guidance: use blue background, single layer grains, avoid blur and shadows.'),
              ),
            ),
            Wrap(
              spacing: 12,
              children: [
                ElevatedButton(
                  onPressed: images.length < 2 ? _takeImage : null,
                  child: Text(images.length < 2 ? 'Take Image ${images.length + 1}' : '2 Images Captured'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (images.isNotEmpty) const Text('Select one image for analysis:'),
            ...images.map(
              (p) => RadioListTile<String>(
                value: p,
                groupValue: selected,
                title: Text(p.split('/').last),
                subtitle: Image.file(File(p), height: 100, fit: BoxFit.cover),
                onChanged: (v) => setState(() => selected = v),
              ),
            ),
            const Spacer(),
            if (!app.weightsAvailable)
              const Text(
                'Model weights missing. Copy rice_model.onnx.data into assets/models/ and rebuild.',
                style: TextStyle(color: Colors.red),
              ),
            ElevatedButton(
              onPressed: (images.length == 2 && selected != null && !running)
                  ? () async {
                      setState(() => running = true);
                      try {
                        final result = await context.read<AppController>().runScan(
                              riceType: riceType,
                              img1Path: images[0],
                              img2Path: images[1],
                              selectedPath: selected!,
                            );
                        if (context.mounted) {
                          Navigator.pushNamed(context, '/results', arguments: result);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Inference failed. Ensure model files exist and photos are clear.\n$e',
                              ),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => running = false);
                      }
                    }
                  : null,
              child: running ? const CircularProgressIndicator() : const Text('Analyze Selected Image'),
            )
          ],
        ),
      ),
    );
  }
}
