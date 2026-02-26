import 'dart:io';

import 'package:image/image.dart' as img;

class PreprocessOutput {
  final List<double> tilesTensor;
  final bool darkWarning;
  final bool blurryWarning;

  PreprocessOutput({
    required this.tilesTensor,
    required this.darkWarning,
    required this.blurryWarning,
  });
}

class PreprocessService {
  static const means = [0.485, 0.456, 0.406];
  static const stds = [0.229, 0.224, 0.225];

  Future<PreprocessOutput> preprocessImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Could not decode image.');
    }

    final darkWarning = _isDark(decoded);
    final blurryWarning = _isBlurry(decoded);
    final tensor = <double>[];

    final tileW = decoded.width / 8.0;
    final tileH = decoded.height / 6.0;

    for (var row = 0; row < 6; row++) {
      for (var col = 0; col < 8; col++) {
        final x = (col * tileW).floor();
        final y = (row * tileH).floor();
        final w = ((col + 1) * tileW).floor() - x;
        final h = ((row + 1) * tileH).floor() - y;
        final tile = img.copyCrop(decoded, x: x, y: y, width: w, height: h);
        final resized = img.copyResize(tile, width: 512, height: 512, interpolation: img.Interpolation.average);
        _appendNchwNormalized(tensor, resized);
      }
    }

    return PreprocessOutput(
      tilesTensor: tensor,
      darkWarning: darkWarning,
      blurryWarning: blurryWarning,
    );
  }

  void _appendNchwNormalized(List<double> target, img.Image image) {
    final channelR = <double>[];
    final channelG = <double>[];
    final channelB = <double>[];

    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final p = image.getPixel(x, y);
        final r = p.r / 255.0;
        final g = p.g / 255.0;
        final b = p.b / 255.0;
        channelR.add((r - means[0]) / stds[0]);
        channelG.add((g - means[1]) / stds[1]);
        channelB.add((b - means[2]) / stds[2]);
      }
    }
    target
      ..addAll(channelR)
      ..addAll(channelG)
      ..addAll(channelB);
  }

  bool _isDark(img.Image image) {
    double sum = 0;
    final sampleStep = (image.width * image.height / 10000).clamp(1, 50).toInt();
    var i = 0;
    var count = 0;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        if (i++ % sampleStep != 0) continue;
        final p = image.getPixel(x, y);
        sum += 0.2126 * p.r + 0.7152 * p.g + 0.0722 * p.b;
        count++;
      }
    }
    final avg = sum / count;
    return avg < 55;
  }

  bool _isBlurry(img.Image image) {
    final gray = img.grayscale(image);
    final laplacianValues = <double>[];
    for (var y = 1; y < gray.height - 1; y += 2) {
      for (var x = 1; x < gray.width - 1; x += 2) {
        final c = gray.getPixel(x, y).r;
        final n = gray.getPixel(x, y - 1).r;
        final s = gray.getPixel(x, y + 1).r;
        final e = gray.getPixel(x + 1, y).r;
        final w = gray.getPixel(x - 1, y).r;
        laplacianValues.add((4 * c - n - s - e - w).toDouble());
      }
    }
    if (laplacianValues.isEmpty) return false;
    final mean = laplacianValues.reduce((a, b) => a + b) / laplacianValues.length;
    final variance = laplacianValues.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / laplacianValues.length;
    return variance < 60;
  }
}
