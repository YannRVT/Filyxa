import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../auth/data/auth_repository.dart';
import '../data/materials_repository.dart';
import '../domain/catalog_reference.dart';
import '../domain/material.dart';
import 'material_widgets.dart';
import 'reference_widgets.dart';

/// Correspondances à confirmer après un import, traitées une par une.
class LinkReviewScreen extends ConsumerStatefulWidget {
  const LinkReviewScreen({super.key});

  @override
  ConsumerState<LinkReviewScreen> createState() => _LinkReviewScreenState();
}

class _LinkReviewScreenState extends ConsumerState<LinkReviewScreen> {
  /// File figée à l'ouverture : la liste ne bouge pas pendant qu'on la traite.
  List<String>? _queue;
  int _index = 0;
  bool _busy = false;
  String? _error;

  void _next() => setState(() {
        _index++;
        _error = null;
      });

  Future<void> _act(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      ref.invalidate(materialsProvider);
      ref.invalidate(linkedReferencesProvider);
      if (mounted) _next();
    } on AuthError catch (e) {
      if (mounted) setState(() => _error = context.l10n.failure(e.failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirm(MaterialItem m, CatalogReference reference) => _act(
        () => ref.read(materialsRepositoryProvider).save(MaterialDraft(
              id: m.id,
              orgId: m.orgId,
              name: m.name,
              photoPath: m.photoPath,
              atelierStockM: m.atelierStockM,
              notes: m.notes,
              pricePerM: m.pricePerM,
              tags: m.tags,
              supplierReferenceId: reference.id,
            )),
      );

  Future<void> _dismiss(MaterialItem m) => _act(() => ref.read(materialsRepositoryProvider).dismissLink(m.id));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final materials = ref.watch(materialsProvider);
    if (_queue == null && materials.hasValue) {
      _queue = [for (final m in ref.read(pendingLinksProvider)) m.id];
    }
    final queue = _queue;
    final all = materials.value ?? const <MaterialItem>[];
    final current = queue == null || _index >= queue.length
        ? null
        : all.where((m) => m.id == queue[_index]).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reviewTitle),
        leading: BackButton(onPressed: _busy ? null : () => context.go('/library')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(FxSpace.md),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: queue == null
                  ? const Padding(padding: EdgeInsets.all(FxSpace.xl), child: Center(child: CircularProgressIndicator()))
                  : !ref.watch(canEditMaterialsProvider)
                      ? MessageBanner.info(l10n.errorEditorsOnly)
                      : _index >= queue.length
                          ? _doneView(l10n)
                          : current == null
                              // Matière supprimée entre-temps : on passe.
                              ? Builder(builder: (_) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) => mounted ? _next() : null);
                                  return const SizedBox.shrink();
                                })
                              : _itemView(l10n, current, queue.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _doneView(AppLocalizations l10n) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: FxSpace.lg),
          const Icon(Icons.check_circle_outline, size: 40, color: FxColors.success),
          const SizedBox(height: FxSpace.sm),
          Text(l10n.reviewDone, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: FxSpace.lg),
          FilledButton(onPressed: () => context.go('/library'), child: Text(l10n.backToLibrary)),
        ],
      );

  Widget _itemView(AppLocalizations l10n, MaterialItem m, int total) {
    final text = Theme.of(context).textTheme;
    final lang = langOf(context);
    final candidates = ref.watch(linkCandidatesProvider(m.id));
    final facts = [
      if (supplierLine(m) != null) supplierLine(m)!,
      if (m.specs.composition.isNotEmpty) compositionCodes(m.specs.composition, lang),
      if (m.specs.weightGsm != null) '${m.specs.weightGsm} g/m²',
    ];
    return Column(
      key: ValueKey(m.id),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.reviewProgress(_index + 1, total), style: text.labelLarge?.copyWith(color: FxColors.inkSoft)),
        const SizedBox(height: FxSpace.xs),
        LinearProgressIndicator(value: (_index + 1) / total),
        const SizedBox(height: FxSpace.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(FxSpace.md),
            child: Row(
              children: [
                SizedBox(width: 56, height: 56, child: MaterialVisual(material: m, iconSize: 22)),
                const SizedBox(width: FxSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.name, style: text.titleMedium),
                      for (final f in facts) TechText(f, size: 12, color: FxColors.inkSoft),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: FxSpace.md),
        Text(l10n.reviewIntro, style: text.bodyMedium?.copyWith(color: FxColors.inkSoft)),
        const SizedBox(height: FxSpace.md),
        if (_error != null) ...[MessageBanner.error(_error!), const SizedBox(height: FxSpace.md)],
        candidates.when(
          loading: () => const Padding(padding: EdgeInsets.all(FxSpace.lg), child: Center(child: CircularProgressIndicator())),
          error: (e, _) => MessageBanner.error(l10n.failure(AuthError.from(e).failure)),
          data: (matches) => matches.isEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MessageBanner.info(l10n.reviewNoCandidate),
                    const SizedBox(height: FxSpace.md),
                    OutlinedButton(onPressed: _busy ? null : () => _dismiss(m), child: Text(l10n.matchNone)),
                  ],
                )
              : MatchChooser(
                  matches: matches,
                  busy: _busy,
                  onConfirm: (r) => _confirm(m, r),
                  onNone: () => _dismiss(m),
                ),
        ),
        const SizedBox(height: FxSpace.sm),
        TextButton(onPressed: _busy ? null : _next, child: Text(l10n.reviewSkip)),
      ],
    );
  }
}
