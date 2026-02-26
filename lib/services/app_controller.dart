import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../models/app_models.dart';
import 'analysis_service.dart';
import 'database_service.dart';
import 'model_asset_service.dart';
import 'onnx_service.dart';
import 'preprocess_service.dart';

class AppController extends ChangeNotifier {
  final DatabaseService db = DatabaseService.instance;
  final ModelAssetService modelAssetsService = ModelAssetService();
  final OnnxService onnxService = OnnxService();
  final PreprocessService preprocessService = PreprocessService();
  final AnalysisService analysisService = AnalysisService();

  UserProfile? user;
  bool disclaimerAccepted = false;
  bool initialized = false;
  bool weightsAvailable = false;
  String modelVersion = 'unknown';
  String? missingWeightsMessage;
  List<ScanRecord> scans = [];

  ModelAssets? _assets;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    disclaimerAccepted = prefs.getBool('disclaimer_accepted') ?? false;
    user = await db.getUser();
    scans = await db.getRecentScans();
    _assets = await modelAssetsService.prepare();
    modelVersion = _assets!.modelVersion;
    weightsAvailable = _assets!.weightsAvailable;
    if (weightsAvailable) {
      try {
        await onnxService.init(_assets!.modelFile, weightsAvailable: true);
      } catch (e) {
        missingWeightsMessage = 'Inference initialization failed: $e';
      }
    } else {
      missingWeightsMessage = 'Model weights missing. Copy rice_model.onnx.data into assets/models/ and rebuild.';
    }
    initialized = true;
    notifyListeners();
  }

  Future<void> acceptDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('disclaimer_accepted', true);
    disclaimerAccepted = true;
    notifyListeners();
  }

  Future<void> saveUserProfile(String name, String role, String org) async {
    final profile = UserProfile(name: name, role: role, organisation: org.isEmpty ? null : org);
    await db.saveUser(profile);
    user = await db.getUser();
    notifyListeners();
  }

  List<double> _riceTypeOneHot(String riceType) {
    switch (riceType) {
      case 'Paddy':
        return [1, 0, 0];
      case 'White':
        return [0, 1, 0];
      case 'Brown':
        return [0, 0, 1];
      default:
        return [0, 1, 0];
    }
  }

  Future<Map<String, dynamic>> runScan({
    required String riceType,
    required String img1Path,
    required String img2Path,
    required String selectedPath,
  }) async {
    if (_assets == null) throw Exception('Model assets not prepared.');
    if (!weightsAvailable) {
      throw Exception('Model weights missing. Copy rice_model.onnx.data into assets/models/ and rebuild.');
    }

    final prep = await preprocessService.preprocessImage(File(selectedPath));
    final infer = await onnxService.run(
      tiles: prep.tilesTensor,
      metaOnehot: _riceTypeOneHot(riceType),
    );

    final result = analysisService.postprocess(
      riceType: riceType,
      countsRaw: infer.counts9,
      measuresRaw: infer.measures6,
      means: _assets!.means,
      stds: _assets!.stds,
    );

    result['image_warnings'] = {
      'too_dark': prep.darkWarning,
      'blurry': prep.blurryWarning,
    };

    final record = ScanRecord(
      id: const Uuid().v4(),
      riceType: riceType,
      img1Path: img1Path,
      img2Path: img2Path,
      selectedPath: selectedPath,
      resultJson: result,
      modelVersion: modelVersion,
    );

    await db.insertScan(record);
    scans = await db.getRecentScans();
    notifyListeners();
    return result;
  }

  Future<File> exportCsv() async {
    final rows = <List<dynamic>>[
      ['id', 'created_at', 'rice_type', 'milling_grade', 'broken_pct', 'warnings', 'result_json']
    ];

    for (final s in scans) {
      final summary = (s.resultJson['summary'] as Map<String, dynamic>? ?? {});
      rows.add([
        s.id,
        s.createdAt.toIso8601String(),
        s.riceType,
        summary['milling_grade'] ?? '',
        summary['broken_pct']?.toString() ?? '',
        (s.resultJson['warnings'] as List<dynamic>? ?? []).join('; '),
        jsonEncode(s.resultJson),
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'rice_scans_export.csv'));
    await file.writeAsString(csvData);
    return file;
  }

  Future<void> shareCsv() async {
    final file = await exportCsv();
    await Share.shareXFiles([XFile(file.path)], text: 'AfricaRice quality scan export');
  }
}
