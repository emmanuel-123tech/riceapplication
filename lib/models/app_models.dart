import 'dart:convert';

class UserProfile {
  final int? id;
  final String name;
  final String role;
  final String? organisation;
  final DateTime createdAt;

  UserProfile({
    this.id,
    required this.name,
    required this.role,
    this.organisation,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'role': role,
        'organisation': organisation,
        'created_at': createdAt.toIso8601String(),
      };

  factory UserProfile.fromMap(Map<String, Object?> map) => UserProfile(
        id: map['id'] as int?,
        name: map['name'] as String,
        role: map['role'] as String,
        organisation: map['organisation'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}

class ScanRecord {
  final String id;
  final DateTime createdAt;
  final String riceType;
  final String img1Path;
  final String img2Path;
  final String selectedPath;
  final Map<String, dynamic> resultJson;
  final String modelVersion;

  ScanRecord({
    required this.id,
    DateTime? createdAt,
    required this.riceType,
    required this.img1Path,
    required this.img2Path,
    required this.selectedPath,
    required this.resultJson,
    required this.modelVersion,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, Object?> toMap() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'rice_type': riceType,
        'img1_path': img1Path,
        'img2_path': img2Path,
        'selected_path': selectedPath,
        'result_json': jsonEncode(resultJson),
        'model_version': modelVersion,
      };

  factory ScanRecord.fromMap(Map<String, Object?> map) => ScanRecord(
        id: map['id'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        riceType: map['rice_type'] as String,
        img1Path: map['img1_path'] as String,
        img2Path: map['img2_path'] as String,
        selectedPath: map['selected_path'] as String,
        resultJson: jsonDecode(map['result_json'] as String) as Map<String, dynamic>,
        modelVersion: map['model_version'] as String,
      );
}
