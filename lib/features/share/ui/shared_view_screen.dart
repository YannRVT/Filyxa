import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../library/domain/catalog.dart';
import '../../library/domain/material.dart';
import '../../library/ui/material_widgets.dart';
import '../../studio/domain/studio.dart';
import '../../studio/ui/studio_widgets.dart';
import '../data/share_repository.dart';

String _date(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

MaterialItem _material(Map<String, dynamic> j) => MaterialItem(
      id: j['id'] as String,
      orgId: '',
      name: j['name'] as String,
      supplierName: j['supplier_name'] as String?,
      supplierCode: j['supplier_code'] as String?,
      colorName: j['color_name'] as String?,
      colorHex: j['color_hex'] as String?,
      supplierReferenceId: j['linked'] == true ? 'linked' : null,
      specs: TextileSpecs.fromJson(j),
    );

/// Modèle public : coloris, rôles, consommation ; matières indexées par identifiant.
(StudioModel, Map<String, MaterialItem>) _model(Map<String, dynamic> j) {
  final materials = <String, MaterialItem>{};
  final colorways = <Colorway>[];
  for (final c in (j['colorways'] as List<dynamic>).cast<Map<String, dynamic>>()) {
    final lines = <BomLine>[];
    for (final (i, l) in (c['lines'] as List<dynamic>).cast<Map<String, dynamic>>().indexed) {
      final m = _material(l['material'] as Map<String, dynamic>);
      materials[m.id] = m;
      lines.add(BomLine(id: '${c['id']}-$i', materialId: m.id, role: l['role'] as String, consumption: (l['consumption'] as num).toDouble()));
    }
    colorways.add(Colorway(
      id: c['id'] as String,
      name: c['name'] as String?,
      position: c['position'] as int? ?? 0,
      quantity: c['quantity'] as int? ?? 0,
      lines: lines,
    ));
  }
  return (
    StudioModel(
      id: j['id'] as String,
      collectionId: '',
      name: j['name'] as String,
      reference: j['reference'] as String?,
      productType: ProductType.parse(j['product_type'] as String?),
      wastePct: (j['waste_pct'] as num?)?.toDouble() ?? kDefaultWastePct,
      colorways: colorways,
    ),
    materials,
  );
}

/// Page publique d'un lien partagé : sans compte, en lecture seule, dans la langue du lien.
class SharedViewScreen extends ConsumerWidget {
  const SharedViewScreen({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(sharedViewProvider(token));
    final lang = view.value?.lang;
    final page = Scaffold(
      backgroundColor: FxColors.cloud,
      body: SafeArea(
        child: view.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Builder(
            builder: (context) => _Status(
              icon: Icons.wifi_off,
              title: context.l10n.sharedNotFoundTitle,
              body: context.l10n.sharedError,
              onRetry: () => ref.invalidate(sharedViewProvider(token)),
            ),
          ),
          data: (v) => Builder(builder: (context) {
            final l10n = context.l10n;
            return switch (v.status) {
              'ok' => _Content(view: v),
              'expired' => _Status(
                  icon: Icons.timer_off_outlined,
                  title: l10n.sharedExpiredTitle,
                  body: l10n.sharedExpiredBody(v.expiresAt == null ? '' : _date(v.expiresAt!)),
                ),
              'revoked' => _Status(icon: Icons.link_off, title: l10n.sharedRevokedTitle, body: l10n.sharedRevokedBody),
              _ => _Status(icon: Icons.help_outline, title: l10n.sharedNotFoundTitle, body: l10n.sharedNotFoundBody),
            };
          }),
        ),
      ),
    );
    // Langue choisie à la création du lien, indépendante du navigateur.
    return lang == null ? page : Localizations.override(context: context, locale: Locale(lang), child: page);
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) => Row(
        children: [
          SvgPicture.asset('assets/brand/filyxa-symbol.svg', height: 24, semanticsLabel: 'Filyxa'),
          const SizedBox(width: FxSpace.sm),
          Text('Filyxa', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: FxColors.petrol)),
        ],
      );
}

class _Status extends StatelessWidget {
  const _Status({required this.icon, required this.title, required this.body, this.onRetry});

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(FxSpace.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _Brand(),
              const SizedBox(height: FxSpace.xl),
              Icon(icon, size: 44, color: FxColors.petrol),
              const SizedBox(height: FxSpace.md),
              Text(title, style: text.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: FxSpace.sm),
              Text(body, style: text.bodyMedium?.copyWith(color: FxColors.inkSoft), textAlign: TextAlign.center),
              if (onRetry != null) ...[
                const SizedBox(height: FxSpace.lg),
                FilledButton(onPressed: onRetry, child: Text(context.l10n.retry)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.view});

  final SharedView view;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final content = view.content;
    final body = switch (view.scope) {
      ShareScope.material => [_MaterialCard(material: _material(content))],
      ShareScope.model => [_ModelView(data: _model(content))],
      _ => [
          Text(content['name'] as String, style: text.headlineSmall),
          const SizedBox(height: FxSpace.md),
          for (final m in (content['models'] as List<dynamic>).cast<Map<String, dynamic>>()) ...[
            _ModelView(data: _model(m)),
            const SizedBox(height: FxSpace.lg),
          ],
        ],
    };
    return ListView(
      padding: const EdgeInsets.all(FxSpace.md),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Brand(),
                const SizedBox(height: FxSpace.xs),
                if (view.organization != null)
                  Text(l10n.sharedFrom(view.organization!), style: text.titleSmall),
                if (view.expiresAt != null)
                  Text(l10n.sharedReadOnly(_date(view.expiresAt!)), style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
                const SizedBox(height: FxSpace.lg),
                ...body,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ModelView extends StatelessWidget {
  const _ModelView({required this.data});

  final (StudioModel, Map<String, MaterialItem>) data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = langOf(context);
    final text = Theme.of(context).textTheme;
    final (model, materials) = data;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(model.name, style: text.titleLarge),
        Text(
          [l10n.productTypeLabel(model.productType), if ((model.reference ?? '').isNotEmpty) model.reference!].join(' · '),
          style: text.bodySmall?.copyWith(color: FxColors.inkSoft),
        ),
        for (final (i, c) in model.colorways.indexed) ...[
          const SizedBox(height: FxSpace.md),
          Text(
            [if (model.hasVariants) l10n.colorwayName(c, i), '${l10n.quantityLabel} : ${c.quantity}'].join(' · '),
            style: text.labelLarge?.copyWith(color: FxColors.petrol),
          ),
          const SizedBox(height: FxSpace.xs),
          if (c.lines.isEmpty) Text(l10n.modelEmptyTitle, style: text.bodySmall),
          for (final l in c.lines)
            if (materials[l.materialId] case final m?)
              Padding(
                padding: const EdgeInsets.only(bottom: FxSpace.sm),
                child: _MaterialCard(
                  material: m,
                  caption: '${l10n.roleText(l.role)} · ${l10n.consumptionLabel} ${formatNumber(l.consumption, lang, decimals: 3)}',
                ),
              ),
        ],
      ],
    );
  }
}

class _MaterialCard extends StatelessWidget {
  const _MaterialCard({required this.material, this.caption});

  final MaterialItem material;

  /// Rôle et consommation dans le modèle.
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = langOf(context);
    final text = Theme.of(context).textTheme;
    final m = material;
    final s = m.specs;
    final facts = [
      if (s.weightGsm != null) '${s.weightGsm} g/m²',
      if (s.widthCm != null) '${s.widthCm} cm',
      if (s.weave != null) weaveLabel(s.weave!, lang),
      if (m.colorName != null) m.colorName!,
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(FxSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (caption != null) Text(caption!.toUpperCase(), style: text.labelSmall?.copyWith(color: FxColors.emeraldInk)),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorFromHex(m.colorHex) ?? FxColors.mintPale,
                    borderRadius: BorderRadius.circular(FxRadius.sm),
                    border: Border.all(color: FxColors.line),
                  ),
                ),
                const SizedBox(width: FxSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.name, style: text.titleMedium),
                      if (supplierLine(m) != null) TechText(supplierLine(m)!, size: 12, color: FxColors.inkSoft),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: FxSpace.sm),
            if (s.composition.isNotEmpty)
              Text(
                s.composition.map((f) => '${formatNumber(f.pct, lang)} % ${fiberLabel(f.fiber, lang)}').join(' · '),
                style: text.bodyMedium,
              ),
            if (facts.isNotEmpty) TechText(facts.join(' · '), size: 13),
            if (s.care.isNotEmpty) ...[
              const SizedBox(height: FxSpace.sm),
              Wrap(spacing: 6, runSpacing: 6, children: [for (final c in sortCare(s.care)) CareIcon(c, size: 26)]),
            ],
            if (s.certifications.isNotEmpty || s.uses.isNotEmpty) ...[
              const SizedBox(height: FxSpace.sm),
              Text(
                [...s.certifications, ...s.uses.map((u) => useLabel(u, lang))].join(' · '),
                style: text.bodySmall?.copyWith(color: FxColors.inkSoft),
              ),
            ],
            if (m.isLinked)
              Padding(
                padding: const EdgeInsets.only(top: FxSpace.xs),
                child: Text(l10n.supplierData, style: text.labelSmall?.copyWith(color: FxColors.emeraldInk)),
              ),
          ],
        ),
      ),
    );
  }
}
