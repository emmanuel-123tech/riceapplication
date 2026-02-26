class AnalysisService {
  static const countLabels = [
    'Count',
    'Broken_Count',
    'Long_Count',
    'Medium_Count',
    'Black_Count',
    'Chalky_Count',
    'Red_Count',
    'Yellow_Count',
    'Green_Count',
  ];

  static const measureLabels = [
    'WK_Length_Average',
    'WK_Width_Average',
    'WK_LW_Ratio_Average',
    'Average_L',
    'Average_a',
    'Average_b',
  ];

  Map<String, dynamic> postprocess({
    required String riceType,
    required List<double> countsRaw,
    required List<double> measuresRaw,
    required List<double> means,
    required List<double> stds,
  }) {
    final counts = <String, int>{};
    for (var i = 0; i < countLabels.length; i++) {
      final val = ((countsRaw[i] / 100.0).round()).clamp(0, 1 << 30);
      counts[countLabels[i]] = val;
    }
    if (riceType == 'Paddy') {
      counts['Chalky_Count'] = 0;
      counts['Medium_Count'] = 0;
      counts['Yellow_Count'] = 0;
      counts['Green_Count'] = 0;
    } else if (riceType == 'Brown') {
      counts['Green_Count'] = 0;
    }

    final measures = <String, double>{};
    for (var i = 0; i < measureLabels.length; i++) {
      measures[measureLabels[i]] = measuresRaw[i] * (stds[i] + 1e-8) + means[i];
    }

    final total = counts['Count']! <= 0 ? 1 : counts['Count']!;
    double pct(String key) => (counts[key]! * 100.0) / total;

    final brokenPct = pct('Broken_Count');
    final longPct = pct('Long_Count');
    final mediumPct = pct('Medium_Count');
    final chalkyPct = pct('Chalky_Count');
    final lwr = measures['WK_LW_Ratio_Average']!;

    final millingGrade = brokenPct < 5
        ? 'Premium'
        : brokenPct <= 10
            ? 'Grade 1'
            : brokenPct <= 15
                ? 'Grade 2'
                : brokenPct <= 20
                    ? 'Grade 3'
                    : 'Below Grade 3';

    final shapeClass = lwr < 2.1
        ? 'Bold'
        : (lwr >= 2.2 && lwr <= 2.9)
            ? 'Medium'
            : 'Slender';

    final grainClass = longPct > 90
        ? 'Long grain'
        : mediumPct > 90
            ? 'Medium grain'
            : 'Mixed';

    final chalkyClass = chalkyPct < 20 ? 'Not chalky' : 'Chalky';

    final warnings = <String>[];
    for (final c in ['Black_Count', 'Green_Count', 'Red_Count', 'Yellow_Count']) {
      if (pct(c) > 10) warnings.add('High ${c.replaceAll('_Count', '').toLowerCase()} percentage');
    }

    return {
      'counts': counts,
      'measures': measures,
      'summary': {
        'milling_grade': millingGrade,
        'shape': shapeClass,
        'grain_type': grainClass,
        'chalkiness': chalkyClass,
        'broken_pct': brokenPct,
      },
      'warnings': warnings,
    };
  }
}
