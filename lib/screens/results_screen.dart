import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final result = (ModalRoute.of(context)?.settings.arguments ?? {}) as Map<String, dynamic>;
    final summary = (result['summary'] as Map<String, dynamic>? ?? {});
    final warnings = (result['warnings'] as List<dynamic>? ?? []);
    final imageWarnings = (result['image_warnings'] as Map<String, dynamic>? ?? {});
    final counts = (result['counts'] as Map<String, dynamic>? ?? {});
    final measures = (result['measures'] as Map<String, dynamic>? ?? {});

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text('Milling grade: ${summary['milling_grade'] ?? '-'}'),
              subtitle: Text(
                'Shape: ${summary['shape'] ?? '-'} | Grain: ${summary['grain_type'] ?? '-'} | Chalkiness: ${summary['chalkiness'] ?? '-'}',
              ),
            ),
          ),
          if (imageWarnings['too_dark'] == true || imageWarnings['blurry'] == true)
            Card(
              color: Colors.amber.shade100,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  'Capture warning: ${imageWarnings['too_dark'] == true ? 'Image may be too dark. ' : ''}${imageWarnings['blurry'] == true ? 'Image may be blurry.' : ''}\nRetake suggested for best accuracy.',
                ),
              ),
            ),
          if (warnings.isNotEmpty)
            ...warnings.map((w) => ListTile(leading: const Icon(Icons.warning), title: Text(w.toString()))),
          ExpansionTile(
            title: const Text('View details'),
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Counts'),
              ),
              ...counts.entries.map((e) => ListTile(title: Text(e.key), trailing: Text('${e.value}'))),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Measures'),
              ),
              ...measures.entries
                  .map((e) => ListTile(title: Text(e.key), trailing: Text((e.value as num).toStringAsFixed(3)))),
            ],
          )
        ],
      ),
    );
  }
}
