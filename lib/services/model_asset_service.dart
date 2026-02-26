import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ModelAssets {
  final File modelFile;
  final File? dataFile;
  final List<double> means;
  final List<double> stds;
  final String modelVersion;

  ModelAssets({
    required this.modelFile,
    required this.dataFile,
    required this.means,
    required this.stds,
    required this.modelVersion,
  });

  bool get weightsAvailable => dataFile?.existsSync() == true;
}

class ModelAssetService {
  static const modelAsset = 'assets/models/rice_model.onnx';
  static const dataAsset = 'assets/models/rice_model.onnx.data';
  static const statsAsset = 'assets/models/m_stats.json';
  static const versionAsset = 'assets/models/model_version.txt';

  Future<ModelAssets> prepare() async {
    final dir = await getApplicationDocumentsDirectory();
    final modelFile = await _copyAssetToFile(modelAsset, p.join(dir.path, 'rice_model.onnx'));
    final dataFile = await _copyOptionalAssetToFile(dataAsset, p.join(dir.path, 'rice_model.onnx.data'));
    final statsRaw = await rootBundle.loadString(statsAsset);
    final stats = jsonDecode(statsRaw) as Map<String, dynamic>;
    final means = (stats['mean'] as List).map((e) => (e as num).toDouble()).toList();
    final stds = (stats['std'] as List).map((e) => (e as num).toDouble()).toList();
    final version = (await rootBundle.loadString(versionAsset)).trim();
    return ModelAssets(
      modelFile: modelFile,
      dataFile: dataFile,
      means: means,
      stds: stds,
      modelVersion: version,
    );
  }

  Future<File> _copyAssetToFile(String asset, String destination) async {
    final bytes = await rootBundle.load(asset);
    final file = File(destination);
    await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
    return file;
  }

  Future<File?> _copyOptionalAssetToFile(String asset, String destination) async {
    try {
      final bytes = await rootBundle.load(asset);
      final file = File(destination);
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      return file;
    } catch (_) {
      return null;
    }
  }
}
