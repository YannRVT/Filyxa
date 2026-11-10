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
      builder: (_) => const _NewAtelierDialog(),
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
        label: Text(l10n.adminNewAtelier),
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
                onRefresh: () => ref.refresh(adminOrganizationsProvider.future),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(FxSpace.md, FxSpace.md, FxSpace.md, 96),
                  itemCount: orgs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: FxSpace.sm),
                  itemBuilder: (context, i) => _OrganizationTile(
                    org: orgs[i],
                    onReinvite: () => _reinvite(context, ref, orgs[i]),
                  ),
                ),
              ),
      ),
    );
  }
}

class _OrganizationTile extends StatelessWidget {
  const _OrganizationTile({required this.org, required this.onReinvite});

  final AdminOrganization org;
  final VoidCallback onReinvite;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final invitation = org.pendingInvitation;
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
                    _Pill(l10n.orgKind(org.organization.kind)),
                  ],
                ),
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
class _NewAtelierDialog extends ConsumerStatefulWidget {
  const _NewAtelierDialog();

  @override
  ConsumerState<_NewAtelierDialog> createState() => _NewAtelierDialogState();
}

class _NewAtelierDialogState extends ConsumerState<_NewAtelierDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
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
          .createAtelierWithAdmin(name: _name.text.trim(), adminEmail: email);
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
      title: Text(l10n.adminNewAtelier),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: l10n.adminOrgName),
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
