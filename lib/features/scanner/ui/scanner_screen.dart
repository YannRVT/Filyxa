import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../library/data/materials_repository.dart';
import '../../library/domain/catalog_reference.dart';
import '../../library/ui/reference_widgets.dart';
import '../../members/data/members_repository.dart';
import '../../session/domain/user_space.dart';
import '../data/scanner_repository.dart';
import '../domain/scan.dart';

/// Photographie d'une étiquette d'échantillon → fiche pré-remplie à valider.
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  bool _busy = false;
  ScanFailure? _failure;
  Uint8List? _lastImage;
  String _lastType = 'image/jpeg';

  Future<void> _pick(ImageSource source) async {
    final file = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 85);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final type = file.mimeType ??
        (file.name.toLowerCase().endsWith('.png')
            ? 'image/png'
            : file.name.toLowerCase().endsWith('.webp')
                ? 'image/webp'
                : 'image/jpeg');
    _lastImage = bytes;
    _lastType = type;
    await _analyze();
  }

  Future<void> _analyze() async {
    final bytes = _lastImage;
    if (bytes == null) return;
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      final outcome = await ref.read(scannerRepositoryProvider).analyze(bytes, _lastType);
      ref.invalidate(scanUsageProvider);
      ref.invalidate(materialsProvider);
      var prefill = outcome.prefill;
      // Rapprochement avec les catalogues publiés : rien n'est lié sans confirmation.
      final matches = await ref
          .read(materialsRepositoryProvider)
          .match(prefill.material.supplierCode, prefill.material.supplierName)
          .catchError((_) => <ReferenceMatch>[]);
      if (!mounted) return;
      if (matches.isNotEmpty) {
        setState(() => _busy = false);
        final choice = await showMatchSheet(context, matches);
        if (!mounted || choice == null) return;
        if (choice.reference != null) prefill = prefill.linkedTo(choice.reference!);
      }
      if (!mounted) return;
      context.go('/library/new', extra: prefill);
    } on ScanException catch (e) {
      ref.invalidate(scanUsageProvider);
      if (mounted) setState(() => _failure = e.failure);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final role = ref.watch(currentRoleProvider);
    final canScan = role?.atLeast(MemberRole.editor) ?? false;
    final usage = ref.watch(scanUsageProvider).value;
    final exhausted = usage?.isExhausted ?? false;
    // Caméra sur mobile ; sur le Web, import d'une photo.
    final hasCamera = !kIsWeb;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanTitle)),
      body: ListView(
        padding: const EdgeInsets.all(FxSpace.md),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!canScan)
                    MessageBanner.info(l10n.errorEditorsOnly)
                  else ...[
                    _Frame(busy: _busy, image: _lastImage),
                    const SizedBox(height: FxSpace.md),
                    Text(l10n.scanIntro, style: text.bodyMedium?.copyWith(color: FxColors.inkSoft)),
                    const SizedBox(height: FxSpace.md),
                    if (usage != null) ...[
                      _UsageLine(usage: usage, isAdmin: role == MemberRole.admin),
                      const SizedBox(height: FxSpace.md),
                    ],
                    if (_failure != null) ...[
                      MessageBanner.error(_failureText(l10n, _failure!)),
                      const SizedBox(height: FxSpace.sm),
                      Wrap(
                        spacing: FxSpace.sm,
                        children: [
                          if (_failure != ScanFailure.quotaExceeded && _lastImage != null)
                            OutlinedButton(onPressed: _busy ? null : _analyze, child: Text(l10n.retry)),
                          TextButton(onPressed: () => context.go('/library/new'), child: Text(l10n.actionCreateManual)),
                        ],
                      ),
                      const SizedBox(height: FxSpace.md),
                    ],
                    if (hasCamera)
                      FilledButton.icon(
                        onPressed: _busy || exhausted ? null : () => _pick(ImageSource.camera),
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: Text(l10n.scanTakePhoto),
                      ),
                    const SizedBox(height: FxSpace.sm),
                    (hasCamera ? OutlinedButton.icon : FilledButton.icon)(
                      onPressed: _busy || exhausted ? null : () => _pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(l10n.scanImportPhoto),
                    ),
                    const SizedBox(height: FxSpace.sm),
                    TextButton(
                      onPressed: _busy ? null : () => context.go('/library/new'),
                      child: Text(l10n.actionCreateManual),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _failureText(AppLocalizations l10n, ScanFailure f) => switch (f) {
        ScanFailure.notALabel => l10n.scanFailureNotLabel,
        ScanFailure.refused => l10n.scanFailureRefused,
        ScanFailure.quotaExceeded => l10n.scanQuotaExhausted,
        ScanFailure.aiUnavailable => l10n.scanFailureAi,
        ScanFailure.imageInvalid => l10n.scanFailureImage,
        ScanFailure.forbidden => l10n.errorEditorsOnly,
        ScanFailure.network => l10n.errorNetwork,
        ScanFailure.generic => l10n.errorGeneric,
      };
}

/// Cadre du scanner : pointillés « point de couture », aperçu de la photo et lecture en cours.
class _Frame extends StatelessWidget {
  const _Frame({required this.busy, required this.image});

  final bool busy;
  final Uint8List? image;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: CustomPaint(
        foregroundPainter: const _DashedBorder(),
        child: Container(
          margin: const EdgeInsets.all(3),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: FxColors.mintPale, borderRadius: BorderRadius.circular(FxRadius.lg)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (image != null)
                Image.memory(image!, fit: BoxFit.cover)
              else
                const Center(child: Icon(Icons.document_scanner_outlined, size: 56, color: FxColors.emeraldInk)),
              if (busy)
                ColoredBox(
                  color: FxColors.petrol.withValues(alpha: 0.72),
                  child: Center(
                    child: Semantics(
                      liveRegion: true,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: FxColors.mint),
                          const SizedBox(height: FxSpace.md),
                          Text(l10n.scanReading, style: const TextStyle(color: FxColors.white, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  const _DashedBorder();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = FxColors.emerald
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(FxRadius.lg + 3)));
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 12) {
        canvas.drawPath(metric.extractPath(d, d + 7), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _UsageLine extends StatelessWidget {
  const _UsageLine({required this.usage, required this.isAdmin});

  final ScanUsage usage;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final color = usage.isExhausted
        ? FxColors.error
        : usage.isWarning
            ? FxColors.warning
            : FxColors.emeraldInk;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.scanUsage(usage.scans, usage.quota),
            style: text.bodySmall?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: usage.ratio.clamp(0, 1).toDouble(),
            minHeight: 6,
            color: color,
            backgroundColor: FxColors.line,
          ),
        ),
        // Avertissements réservés aux admins (80 %) ; le blocage est visible de tous.
        if (usage.isExhausted) ...[
          const SizedBox(height: FxSpace.sm),
          MessageBanner.error(l10n.scanQuotaExhausted),
        ] else if (usage.isWarning && isAdmin) ...[
          const SizedBox(height: FxSpace.sm),
          MessageBanner.warning(l10n.scanQuotaWarning((usage.ratio * 100).floor())),
        ],
      ],
    );
  }
}
