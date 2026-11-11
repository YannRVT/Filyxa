import '../../library/domain/material.dart';

/// Fiche pré-remplie par la lecture d'une étiquette, à valider dans le formulaire.
class ScanPrefill {
  const ScanPrefill({required this.material, this.uncertain = const {}});

  /// Réponse de l'Edge Function analyze-tag (champ « label »).
  factory ScanPrefill.fromLabel(Map<String, dynamic> label) {
    List<String> strings(String key) => (label[key] as List<dynamic>? ?? const []).cast<String>();
    return ScanPrefill(
      material: MaterialItem(
        id: '',
        orgId: '',
        name: label['name'] as String? ?? '',
        supplierName: label['supplier_name'] as String?,
        supplierCode: label['supplier_code'] as String?,
        colorName: label['color_name'] as String?,
        colorHex: label['color_hex'] as String?,
        notes: label['notes'] as String?,
        specs: TextileSpecs(
          composition: (label['composition'] as List<dynamic>? ?? const [])
              .map((e) => FiberShare.fromJson(e as Map<String, dynamic>))
              .toList(),
          weightGsm: label['weight_gsm'] as int?,
          widthCm: label['width_cm'] as int?,
          weave: label['weave'] as String?,
          care: strings('care'),
          certifications: strings('certifications'),
          uses: strings('uses'),
        ),
      ),
      uncertain: strings('uncertain_fields').toSet(),
    );
  }

  final MaterialItem material;

  /// Champs lus avec peu de certitude (noms du formulaire : weight_gsm, color_hex…).
  final Set<String> uncertain;
}

/// Usage du mois : scans consommés et quota de l'atelier.
class ScanUsage {
  const ScanUsage({required this.scans, required this.quota});

  factory ScanUsage.fromJson(Map<String, dynamic> json) =>
      ScanUsage(scans: json['scans'] as int? ?? 0, quota: json['quota'] as int? ?? 0);

  final int scans;
  final int quota;

  double get ratio => quota <= 0 ? 1 : scans / quota;

  /// Avertissement à 80 % du quota, blocage à 100 %.
  bool get isWarning => ratio >= 0.8 && !isExhausted;
  bool get isExhausted => scans >= quota;
}

/// Motif d'échec d'un scan, traduit par l'interface.
enum ScanFailure { notALabel, refused, quotaExceeded, aiUnavailable, imageInvalid, forbidden, network, generic }

ScanFailure scanFailureOf(String? code, {int? status}) => switch (code) {
      'not_a_label' || 'analysis_unreadable' || 'analysis_empty' || 'analysis_incomplete' => ScanFailure.notALabel,
      'analysis_refused' => ScanFailure.refused,
      'quota_exceeded' => ScanFailure.quotaExceeded,
      'ai_busy' || 'ai_unavailable' || 'ai_misconfigured' => ScanFailure.aiUnavailable,
      'image_missing' || 'image_format' || 'image_too_large' => ScanFailure.imageInvalid,
      'forbidden' => ScanFailure.forbidden,
      _ => status == null ? ScanFailure.network : ScanFailure.generic,
    };

/// Matière existante avec le même code article (sans espaces, tirets ni casse).
MaterialItem? findDuplicate(List<MaterialItem> materials, {String? supplierCode, String? exceptId}) {
  final code = normalizeCode(supplierCode);
  if (code.isEmpty) return null;
  for (final m in materials) {
    if (m.id != exceptId && normalizeCode(m.supplierCode) == code) return m;
  }
  return null;
}

String normalizeCode(String? code) => (code ?? '').toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
