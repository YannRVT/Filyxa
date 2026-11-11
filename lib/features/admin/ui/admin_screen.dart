import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/auth_rules.dart';
import '../../session/data/user_space_repository.dart';
import '../../session/domain/user_space.dart';
import '../data/admin_repository.dart';

/// Console super-admin : création des ateliers pilotes et invitation de leur admin.
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  Future<void> _createAtelier(BuildContext context, WidgetRef ref) async {
    final email = await showDialog<String>(
      context: context,
      builder: (_) => const _NewOrganizationDialog(),
    );
    if (email == null || !context.mounted) return;
    ref.invalidate(adminOrganizationsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.adminCreated(email))),
    );
  }

  Future<void> _reinvite(BuildContext context, WidgetRef ref, AdminOrganization org) async {
    final email = org.pendingInvitation?.email;
    if (email == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await ref
          .read(adminRepositoryProvider)
          .invite(orgId: org.organization.id, email: email, role: MemberRole.admin);
      ref.invalidate(adminOrganizationsProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminReinvited(email))));
    } on AuthError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.failure(e.failure))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final organizations = ref.watch(adminOrganizationsProvider);
    final hasOrganization = ref.watch(userSpaceProvider).value?.hasOrganization ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminTitle),
        leading: hasOrganization ? BackButton(onPressed: () => context.go('/account')) : null,
        actions: [
          if (!hasOrganization)
            IconButton(
              tooltip: l10n.logout,
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(authRepositoryProvider).signOut(),
            ),
          const SizedBox(width: FxSpace.sm),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: FxColors.petrol,
        foregroundColor: FxColors.white,
        onPressed: () => _createAtelier(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.adminNewOrg),
      ),
      body: organizations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(FxSpace.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MessageBanner.error(l10n.loadingError),
                const SizedBox(height: FxSpace.md),
                FilledButton(
                  onPressed: () => ref.invalidate(adminOrganizationsProvider),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (orgs) => orgs.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(FxSpace.lg),
                  child: Text(
                    l10n.adminEmpty,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: FxColors.inkSoft),
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: () {
                  ref.invalidate(adminUsageProvider);
                  return ref.refresh(adminOrganizationsProvider.future);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(FxSpace.md, FxSpace.md, FxSpace.md, 96),
                  itemCount: orgs.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: FxSpace.sm),
                  itemBuilder: (context, i) => i == 0
                      ? const _UsageHeader()
                      : _OrganizationTile(
                          org: orgs[i - 1],
                          onReinvite: () => _reinvite(context, ref, orgs[i - 1]),
                        ),
                ),
              ),
      ),
    );
  }
}

class _OrganizationTile extends ConsumerWidget {
  const _OrganizationTile({required this.org, required this.onReinvite});

  final AdminOrganization org;
  final VoidCallback onReinvite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final invitation = org.pendingInvitation;
    final usage = ref.watch(adminUsageProvider).value?[org.organization.id];
    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).add_Hm();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(FxSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(org.organization.name, style: text.titleMedium)),
                    if (usage != null) ...[_Pill(l10n.planLabel(usage.plan)), const SizedBox(width: FxSpace.xs)],
                    _Pill(l10n.orgKind(org.organization.kind)),
                  ],
                ),
                if (usage != null) ...[
                  const SizedBox(height: FxSpace.sm),
                  _UsageLine(usage: usage, kind: org.organization.kind),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => showDialog<void>(context: context, builder: (_) => _PlanDialog(orgId: org.organization.id, usage: usage)),
                      icon: const Icon(Icons.tune, size: 18),
                      label: Text(l10n.adminEditPlan),
                    ),
                  ),
                ],
                const SizedBox(height: FxSpace.xs),
                Text(
                  l10n.adminMembers(org.memberCount),
                  style: text.bodyMedium?.copyWith(color: FxColors.inkSoft),
                ),
                if (invitation != null) ...[
                  const SizedBox(height: FxSpace.sm),
                  Row(
                    children: [
                      Icon(
                        invitation.isExpired ? Icons.schedule : Icons.mark_email_unread_outlined,
                        size: 18,
                        color: invitation.isExpired ? FxColors.warning : FxColors.emeraldInk,
                      ),
                      const SizedBox(width: FxSpace.sm),
                      Expanded(
                        child: Text(
                          invitation.isExpired
                              ? l10n.adminInviteExpired(invitation.email)
                              : l10n.adminInvitePending(
                                  invitation.email,
                                  dateFormat.format(invitation.expiresAt),
                                ),
                          style: text.bodyMedium,
                        ),
                      ),
                      TextButton(onPressed: onReinvite, child: Text(l10n.adminReinvite)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension _PlanTexts on AppLocalizations {
  String planLabel(String plan) => switch (plan) {
        'pilot' => plan_pilot,
        'essential' => plan_essential,
        'pro' => plan_pro,
        'custom' => plan_custom,
        _ => plan,
      };
}

String _usd(BuildContext context, double v) =>
    NumberFormat.simpleCurrency(locale: Localizations.localeOf(context).toLanguageTag(), name: 'USD').format(v);
String _count(BuildContext context, int v) => NumberFormat.decimalPattern(Localizations.localeOf(context).toLanguageTag()).format(v);

/// Mois affiché, coût total et tarif du modèle.
class _UsageHeader extends ConsumerWidget {
  const _UsageHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final month = ref.watch(adminMonthProvider);
    final usage = ref.watch(adminUsageProvider);
    final pricing = ref.watch(aiPricingProvider).value;
    final total = (usage.value?.values ?? const <OrgUsage>[]).fold<double>(0, (s, u) => s + u.costUsd);
    final now = DateTime.now();
    final isCurrent = month.year == now.year && month.month == now.month;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: Card(
          color: FxColors.mintPale,
          child: Padding(
            padding: const EdgeInsets.all(FxSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: l10n.adminPreviousMonth,
                      onPressed: () => ref.read(adminMonthProvider.notifier).shift(-1),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      DateFormat.yMMMM(Localizations.localeOf(context).toLanguageTag()).format(month),
                      style: text.titleMedium,
                    ),
                    IconButton(
                      tooltip: l10n.adminNextMonth,
                      onPressed: isCurrent ? null : () => ref.read(adminMonthProvider.notifier).shift(1),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                if (usage.hasError) MessageBanner.error(l10n.failure(AuthError.from(usage.error!).failure)),
                Text(l10n.adminTotalCost(_usd(context, total)), style: text.titleSmall),
                if (pricing != null)
                  TextButton.icon(
                    onPressed: () => showDialog<void>(context: context, builder: (_) => _PricingDialog(pricing: pricing)),
                    icon: const Icon(Icons.price_change_outlined, size: 18),
                    label: Text(
                      '${l10n.adminPricingTitle} : ${_usd(context, pricing.inputPerMtok)} / ${_usd(context, pricing.outputPerMtok)}',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Scans du mois face au quota, membres, contenu, jetons et coût.
class _UsageLine extends StatelessWidget {
  const _UsageLine({required this.usage, required this.kind});

  final OrgUsage usage;
  final OrgKind kind;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final u = usage;
    final ratio = u.scanQuota == 0 ? (u.scans > 0 ? 1.0 : 0.0) : (u.scans / u.scanQuota).clamp(0.0, 1.0);
    final color = ratio >= 1 ? FxColors.error : (ratio >= 0.8 ? FxColors.warning : FxColors.emerald);
    final muted = text.bodySmall?.copyWith(color: FxColors.inkSoft);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (kind == OrgKind.atelier) ...[
          Text(l10n.adminScans(u.scans, u.scanQuota), style: text.bodyMedium),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: ratio, minHeight: 6, color: color, backgroundColor: FxColors.line),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          [
            l10n.adminMembers(u.members),
            kind == OrgKind.atelier ? l10n.adminItemsAtelier(u.items) : l10n.adminItemsSupplier(u.items),
          ].join(' · '),
          style: muted,
        ),
        if (kind == OrgKind.atelier) ...[
          Text(l10n.adminTokens(_count(context, u.inputTokens), _count(context, u.outputTokens)), style: muted),
          Text(l10n.adminCost(_usd(context, u.costUsd)), style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ],
    );
  }
}

class _PlanDialog extends ConsumerStatefulWidget {
  const _PlanDialog({required this.orgId, required this.usage});

  final String orgId;
  final OrgUsage usage;

  @override
  ConsumerState<_PlanDialog> createState() => _PlanDialogState();
}

class _PlanDialogState extends ConsumerState<_PlanDialog> {
  late String _plan = adminPlans.containsKey(widget.usage.plan) ? widget.usage.plan : 'pilot';
  late final _quota = TextEditingController(text: '${widget.usage.scanQuota}');
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _quota.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final text = _quota.text.trim();
    final quota = text.isEmpty ? null : int.tryParse(text);
    if ((text.isNotEmpty && (quota == null || quota < 0)) || (quota == null && adminPlans[_plan] == null)) {
      setState(() => _error = l10n.errorNumberRange(0, 1000000));
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(adminRepositoryProvider).setPlan(widget.orgId, _plan, quota);
      ref.invalidate(adminUsageProvider);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminPlanSaved)));
    } on AuthError catch (e) {
      if (mounted) setState(() => _error = l10n.failure(e.failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.adminEditPlan),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _plan,
              decoration: InputDecoration(labelText: l10n.adminPlan),
              items: [
                for (final e in adminPlans.entries)
                  DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value == null ? l10n.planLabel(e.key) : '${l10n.planLabel(e.key)} · ${e.value}'),
                  ),
              ],
              onChanged: (v) => setState(() {
                _plan = v ?? _plan;
                // Offre standard : on propose son quota par défaut.
                if (adminPlans[_plan] != null) _quota.text = '${adminPlans[_plan]}';
              }),
            ),
            const SizedBox(height: FxSpace.sm),
            TextField(
              controller: _quota,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.adminQuota, helperText: l10n.adminQuotaHint),
            ),
            if (_error != null) ...[const SizedBox(height: FxSpace.sm), MessageBanner.error(_error!)],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.save)),
      ],
    );
  }
}

class _PricingDialog extends ConsumerStatefulWidget {
  const _PricingDialog({required this.pricing});

  final AiPricing pricing;

  @override
  ConsumerState<_PricingDialog> createState() => _PricingDialogState();
}

class _PricingDialogState extends ConsumerState<_PricingDialog> {
  late final _input = TextEditingController(text: '${widget.pricing.inputPerMtok}');
  late final _output = TextEditingController(text: '${widget.pricing.outputPerMtok}');
  String? _error;

  @override
  void dispose() {
    _input.dispose();
    _output.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final input = double.tryParse(_input.text.trim().replaceAll(',', '.'));
    final output = double.tryParse(_output.text.trim().replaceAll(',', '.'));
    if (input == null || output == null || input < 0 || output < 0) {
      setState(() => _error = l10n.errorNumberRange(0, 1000));
      return;
    }
    try {
      await ref.read(adminRepositoryProvider).setPricing(AiPricing(inputPerMtok: input, outputPerMtok: output));
      ref.invalidate(aiPricingProvider);
      ref.invalidate(adminUsageProvider);
      if (mounted) Navigator.of(context).pop();
    } on AuthError catch (e) {
      if (mounted) setState(() => _error = l10n.failure(e.failure));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.adminPricingTitle),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _input,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.adminPricingInput, prefixText: r'$ '),
            ),
            TextField(
              controller: _output,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.adminPricingOutput, prefixText: r'$ '),
            ),
            if (_error != null) ...[const SizedBox(height: FxSpace.sm), MessageBanner.error(_error!)],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: FxColors.mintPale,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(color: FxColors.petrol, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

/// Création d'un atelier et invitation de son admin. Renvoie l'e-mail invité.
class _NewOrganizationDialog extends ConsumerStatefulWidget {
  const _NewOrganizationDialog();

  @override
  ConsumerState<_NewOrganizationDialog> createState() => _NewOrganizationDialogState();
}

class _NewOrganizationDialogState extends ConsumerState<_NewOrganizationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  OrgKind _kind = OrgKind.atelier;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final email = normalizeEmail(_email.text);
      await ref
          .read(adminRepositoryProvider)
          .createOrganizationWithAdmin(name: _name.text.trim(), adminEmail: email, kind: _kind);
      if (mounted) Navigator.of(context).pop(email);
    } on AuthError catch (e) {
      ref.invalidate(adminOrganizationsProvider);
      if (mounted) setState(() => _error = context.l10n.failure(e.failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.adminNewOrg),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.adminOrgKind, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: FxSpace.xs),
              SegmentedButton<OrgKind>(
                segments: [
                  ButtonSegment(value: OrgKind.atelier, label: Text(l10n.orgKindAtelier), icon: const Icon(Icons.storefront_outlined)),
                  ButtonSegment(value: OrgKind.supplier, label: Text(l10n.orgKindSupplier), icon: const Icon(Icons.local_shipping_outlined)),
                ],
                selected: {_kind},
                onSelectionChanged: (s) => setState(() => _kind = s.first),
              ),
              const SizedBox(height: FxSpace.md),
              TextFormField(
                controller: _name,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: l10n.adminOrgNameGeneric),
                validator: (v) {
                  final length = (v ?? '').trim().length;
                  return length >= 2 && length <= 120 ? null : l10n.errorOrgName;
                },
              ),
              const SizedBox(height: FxSpace.md),
              EmailField(
                controller: _email,
                label: l10n.adminAdminEmail,
                onSubmitted: (_) => _submit(),
              ),
              if (_error != null) ...[
                const SizedBox(height: FxSpace.md),
                MessageBanner.error(_error!),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        BusyButton(label: l10n.adminCreate, busy: _busy, onPressed: _submit),
      ],
    );
  }
}
