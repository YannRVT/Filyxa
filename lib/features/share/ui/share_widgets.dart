import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../auth/data/auth_repository.dart';
import '../../export/export_screen.dart' show pdfLanguages;
import '../../library/data/materials_repository.dart';
import '../../library/domain/material.dart';
import '../../session/data/user_space_repository.dart';
import '../../studio/data/studio_repository.dart';
import '../data/share_repository.dart';

String _date(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

extension ShareTexts on AppLocalizations {
  String shareScopeLabel(ShareScope s) => switch (s) {
        ShareScope.material => shareScopeMaterial,
        ShareScope.model => shareScopeModel,
        ShareScope.collection => shareScopeCollection,
      };
}

/// Copie, modification de l'expiration et révocation d'un lien.
Future<void> _copy(BuildContext context, ShareLink link) async {
  final messenger = ScaffoldMessenger.of(context);
  final copied = context.l10n.shareCopied;
  await Clipboard.setData(ClipboardData(text: link.url));
  messenger.showSnackBar(SnackBar(content: Text(copied)));
}

Future<void> _changeExpiry(BuildContext context, WidgetRef ref, ShareLink link) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final now = DateTime.now();
  final picked = await showDatePicker(
    context: context,
    initialDate: link.expiresAt.isAfter(now) ? link.expiresAt : now.add(const Duration(days: 1)),
    firstDate: now.add(const Duration(days: 1)),
    lastDate: now.add(const Duration(days: 366)),
    helpText: l10n.shareExtend,
  );
  if (picked == null) return;
  try {
    await ref.read(shareRepositoryProvider).setExpiry(link.id, DateTime(picked.year, picked.month, picked.day, 23, 59));
    ref.invalidate(shareLinksProvider);
  } on AuthError catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.failure(e.failure))));
  }
}

Future<void> _revoke(BuildContext context, WidgetRef ref, ShareLink link) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (d) => AlertDialog(
      title: Text(l10n.shareRevoke),
      content: Text(l10n.shareRevokeConfirm),
      actions: [
        TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(l10n.cancel)),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: FxColors.error),
          onPressed: () => Navigator.of(d).pop(true),
          child: Text(l10n.shareRevoke),
        ),
      ],
    ),
  );
  if (ok != true) return;
  try {
    await ref.read(shareRepositoryProvider).revoke(link.id);
    ref.invalidate(shareLinksProvider);
    messenger.showSnackBar(SnackBar(content: Text(l10n.shareRevoked)));
  } on AuthError catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.failure(e.failure))));
  }
}

/// Un lien actif : adresse, langue, expiration et actions.
class ShareLinkTile extends ConsumerWidget {
  const ShareLinkTile({super.key, required this.link, this.title});

  final ShareLink link;
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final canEdit = ref.watch(canEditMaterialsProvider);
    return Container(
      margin: const EdgeInsets.only(bottom: FxSpace.sm),
      padding: const EdgeInsets.all(FxSpace.sm),
      decoration: BoxDecoration(border: Border.all(color: FxColors.line), borderRadius: BorderRadius.circular(FxRadius.sm)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) Text(title!, style: text.titleSmall),
          SelectableText(link.url, style: text.bodySmall?.copyWith(fontFamily: 'monospace')),
          Text('${pdfLanguages[link.lang] ?? link.lang} · ${l10n.shareExpires(_date(link.expiresAt))}',
              style: text.labelSmall?.copyWith(color: FxColors.inkSoft)),
          Wrap(
            spacing: FxSpace.xs,
            children: [
              TextButton.icon(onPressed: () => _copy(context, link), icon: const Icon(Icons.copy, size: 16), label: Text(l10n.shareCopy)),
              if (canEdit) ...[
                TextButton.icon(
                  onPressed: () => _changeExpiry(context, ref, link),
                  icon: const Icon(Icons.event_outlined, size: 16),
                  label: Text(l10n.shareExtend),
                ),
                TextButton.icon(
                  onPressed: () => _revoke(context, ref, link),
                  icon: const Icon(Icons.link_off, size: 16, color: FxColors.error),
                  label: Text(l10n.shareRevoke, style: const TextStyle(color: FxColors.error)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Bouton « Partager » d'une fiche, d'un modèle ou d'une collection (Éditeurs).
class ShareButton extends ConsumerWidget {
  const ShareButton({super.key, required this.scope, required this.targetId});

  final ShareScope scope;
  final String targetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(canEditMaterialsProvider)) return const SizedBox.shrink();
    final active = ref.watch(targetLinksProvider((scope, targetId))).length;
    return IconButton(
      tooltip: context.l10n.shareAction,
      onPressed: () => showDialog<void>(context: context, builder: (_) => ShareDialog(scope: scope, targetId: targetId)),
      icon: Badge(isLabelVisible: active > 0, label: Text('$active'), child: const Icon(Icons.ios_share)),
    );
  }
}

class ShareDialog extends ConsumerStatefulWidget {
  const ShareDialog({super.key, required this.scope, required this.targetId});

  final ShareScope scope;
  final String targetId;

  @override
  ConsumerState<ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends ConsumerState<ShareDialog> {
  late final _days = TextEditingController(text: '$kShareDefaultDays');
  String? _lang;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _days.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final days = int.tryParse(_days.text.trim());
    if (days == null || days < 1 || days > 365) {
      setState(() => _error = context.l10n.errorNumberRange(1, 365));
      return;
    }
    final lang = _lang ?? Localizations.localeOf(context).languageCode;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final orgId = (await ref.read(userSpaceProvider.future))?.membership?.organization.id;
      if (orgId == null) return;
      final link = await ref
          .read(shareRepositoryProvider)
          .create(orgId, widget.scope, widget.targetId, lang: pdfLanguages.containsKey(lang) ? lang : 'fr', days: days);
      ref.invalidate(shareLinksProvider);
      if (mounted) await _copy(context, link);
    } on AuthError catch (e) {
      if (mounted) setState(() => _error = context.l10n.failure(e.failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final active = ref.watch(targetLinksProvider((widget.scope, widget.targetId)));
    final uiLang = Localizations.localeOf(context).languageCode;
    return AlertDialog(
      title: Text(l10n.shareTitle),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.shareIntro, style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
              const SizedBox(height: FxSpace.md),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _lang ?? (pdfLanguages.containsKey(uiLang) ? uiLang : 'fr'),
                      decoration: InputDecoration(labelText: l10n.shareLanguage),
                      items: [for (final e in pdfLanguages.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
                      onChanged: (v) => setState(() => _lang = v),
                    ),
                  ),
                  const SizedBox(width: FxSpace.md),
                  SizedBox(
                    width: 130,
                    child: TextField(
                      controller: _days,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(labelText: l10n.shareValidity),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FxSpace.md),
              FilledButton.icon(
                onPressed: _busy ? null : _create,
                icon: const Icon(Icons.add_link),
                label: Text(l10n.shareCreate),
              ),
              if (_error != null) ...[const SizedBox(height: FxSpace.sm), MessageBanner.error(_error!)],
              const SizedBox(height: FxSpace.lg),
              Text(l10n.shareActiveLinks, style: text.titleSmall),
              const SizedBox(height: FxSpace.sm),
              if (active.isEmpty) Text(l10n.shareNone, style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
              for (final l in active) ShareLinkTile(link: l),
            ],
          ),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(MaterialLocalizations.of(context).closeButtonLabel))],
    );
  }
}

/// Compte › Liens partagés : tous les liens actifs de l'atelier.
class ShareLinksScreen extends ConsumerWidget {
  const ShareLinksScreen({super.key});

  String _title(WidgetRef ref, AppLocalizations l10n, ShareLink l) {
    final name = switch (l.scope) {
      ShareScope.material =>
        (ref.watch(materialsProvider).value ?? const <MaterialItem>[]).where((m) => m.id == l.targetId).firstOrNull?.name,
      ShareScope.model => ref.watch(modelProvider(l.targetId)).value?.name,
      ShareScope.collection => (ref.watch(collectionsProvider).value ?? const []).where((c) => c.id == l.targetId).firstOrNull?.name,
    };
    return '${l10n.shareScopeLabel(l.scope)} · ${name ?? l10n.shareUnknownTarget}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final links = ref.watch(shareLinksProvider);
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shareLinksTitle),
        leading: BackButton(onPressed: () => context.go('/account')),
      ),
      body: links.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: MessageBanner.error(l10n.failure(AuthError.from(e).failure))),
        data: (all) {
          final active = all.where((l) => l.isActive(now)).toList();
          return ListView(
            padding: const EdgeInsets.all(FxSpace.md),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (active.isEmpty) Padding(padding: const EdgeInsets.all(FxSpace.lg), child: Text(l10n.shareNone)),
                      for (final l in active) ShareLinkTile(link: l, title: _title(ref, l10n, l)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
