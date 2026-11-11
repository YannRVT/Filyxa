/// Champ d'une référence fournisseur sur lequel porte un signalement.
enum ReportField {
  name,
  color,
  composition,
  weight,
  width,
  weave,
  care,
  certifications,
  uses,
  availability,
  other;

  static ReportField parse(String? v) => values.firstWhere((f) => f.name == v, orElse: () => other);
}

enum ReportStatus {
  open,
  fixed,
  rejected;

  static ReportStatus parse(String? v) => values.firstWhere((s) => s.name == v, orElse: () => open);
}

/// Signalement vu par l'atelier (sur la fiche de sa matière).
class ErrorReport {
  const ErrorReport({
    required this.id,
    required this.field,
    required this.observedValue,
    required this.status,
    required this.createdAt,
    this.comment,
    this.response,
    this.shareIdentity = false,
    this.resolvedAt,
  });

  factory ErrorReport.fromJson(Map<String, dynamic> json) => ErrorReport(
        id: json['id'] as String,
        field: ReportField.parse(json['field'] as String?),
        observedValue: json['observed_value'] as String,
        comment: json['comment'] as String?,
        status: ReportStatus.parse(json['status'] as String?),
        response: json['response'] as String?,
        shareIdentity: json['share_identity'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
        resolvedAt: json['resolved_at'] == null ? null : DateTime.parse(json['resolved_at'] as String).toLocal(),
      );

  static const selectColumns = 'id, field, observed_value, comment, status, response, share_identity, created_at, resolved_at';

  final String id;
  final ReportField field;
  final String observedValue;
  final String? comment;
  final ReportStatus status;

  /// Message du fournisseur ; motif obligatoire en cas de rejet.
  final String? response;
  final bool shareIdentity;
  final DateTime createdAt;
  final DateTime? resolvedAt;
}

/// Signalement vu par le fournisseur : atelier masqué sauf partage choisi par celui-ci.
class SupplierErrorReport {
  const SupplierErrorReport({
    required this.id,
    required this.referenceId,
    required this.referenceCode,
    required this.referenceName,
    required this.field,
    required this.observedValue,
    required this.status,
    required this.createdAt,
    this.comment,
    this.atelierName,
    this.response,
  });

  factory SupplierErrorReport.fromJson(Map<String, dynamic> json) => SupplierErrorReport(
        id: json['id'] as String,
        referenceId: json['reference_id'] as String,
        referenceCode: json['reference_code'] as String,
        referenceName: json['reference_name'] as String,
        field: ReportField.parse(json['field'] as String?),
        observedValue: json['observed_value'] as String,
        comment: json['comment'] as String?,
        atelierName: json['atelier_name'] as String?,
        status: ReportStatus.parse(json['status'] as String?),
        response: json['response'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      );

  final String id;
  final String referenceId;
  final String referenceCode;
  final String referenceName;
  final ReportField field;
  final String observedValue;
  final String? comment;

  /// null = atelier anonyme.
  final String? atelierName;
  final ReportStatus status;
  final String? response;
  final DateTime createdAt;
}

enum NotificationKind {
  reportNew,
  reportFixed,
  reportRejected;

  static NotificationKind? parse(String? v) => switch (v) {
        'report_new' => reportNew,
        'report_fixed' => reportFixed,
        'report_rejected' => reportRejected,
        _ => null,
      };
}

/// Notification dans l'app (cloche).
class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.createdAt,
    this.materialId,
    this.referenceId,
    this.data = const {},
    this.readAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as String,
        kind: NotificationKind.parse(json['kind'] as String?) ?? NotificationKind.reportNew,
        materialId: json['material_id'] as String?,
        referenceId: json['reference_id'] as String?,
        data: (json['data'] as Map<String, dynamic>?) ?? const {},
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
        readAt: json['read_at'] == null ? null : DateTime.parse(json['read_at'] as String).toLocal(),
      );

  static const selectColumns = 'id, kind, material_id, reference_id, data, created_at, read_at';

  final String id;
  final NotificationKind kind;
  final String? materialId;
  final String? referenceId;

  /// Textes figés à l'événement : code, name, field, response.
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get unread => readAt == null;
  ReportField get field => ReportField.parse(data['field'] as String?);
}
