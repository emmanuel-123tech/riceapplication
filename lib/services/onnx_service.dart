import 'dart:io';

import 'package:onnxruntime/onnxruntime.dart';

class InferenceOutput {
  final List<double> counts9;
  final List<double> measures6;

  InferenceOutput({required this.counts9, required this.measures6});
}

class OnnxService {
  OrtSession? _session;

  Future<void> init(File modelFile, {required bool weightsAvailable}) async {
    if (!weightsAvailable) {
      throw Exception('Model weights missing. Copy rice_model.onnx.data into assets/models/ and rebuild.');
    }
    OrtEnv.instance.init();
    final options = OrtSessionOptions();
    _session = OrtSession.fromFile(modelFile, options);
  }

  Future<InferenceOutput> run({
    required List<double> tiles,
    required List<double> metaOnehot,
  }) async {
    final session = _session;
    if (session == null) throw Exception('Model not initialized.');

    final inputTiles = OrtValueTensor.createTensorWithDataList(tiles, [1, 48, 3, 512, 512]);
    final inputMeta = OrtValueTensor.createTensorWithDataList(metaOnehot, [1, 3]);
    final runOptions = OrtRunOptions();

    final outputs = await session.runAsync(runOptions, {
      'tiles': inputTiles,
      'meta_onehot': inputMeta,
    });

    final counts = _flattenToDouble(outputs[0]?.value);
    final measures = _flattenToDouble(outputs[1]?.value);

    inputTiles.release();
    inputMeta.release();
    runOptions.release();

    return InferenceOutput(counts9: counts, measures6: measures);
  }

  List<double> _flattenToDouble(dynamic value) {
    if (value is List<double>) return value;
    if (value is List) {
      if (value.isNotEmpty && value.first is List) {
        return (value.first as List).map((e) => (e as num).toDouble()).toList();
      }
      return value.map((e) => (e as num).toDouble()).toList();
    }
    throw Exception('Unexpected output tensor format.');
  }

  void dispose() {
    _session?.release();
    _session = null;
  }
}
