import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/auth_rules.dart';
import '../../session/data/user_space_repository.dart';
import '../../session/domain/user_space.dart';
import '../data/members_repository.dart';
import '../domain/member.dart';

/// Membres de l'atelier. Tout membre consulte la liste ; seuls les admins invitent,
/// changent un rôle, retirent un membre ou annulent une invitation.
class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isAdmin = ref.watch(currentRoleProvider) == MemberRole.admin;
    final overview = ref.watch(membersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.membersTitle),
        leading: BackButton(onPressed: () => context.go('/account')),
        actions: [
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.only(right: FxSpace.md),
              child: FilledButton.icon(
                onPressed: () => _invite(context, ref),
                icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                label: Text(l10n.membersInvite),
              ),
            ),
        ],
      ),
      body: overview.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(FxSpace.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MessageBanner.error(l10n.loadingError),
                const SizedBox(height: FxSpace.md),
                FilledButton(
                  onPressed: () => ref.invalidate(membersProvider),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.refresh(membersProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(FxSpace.md),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Column(
                          children: [
                            for (final (i, member) in data.members.indexed) ...[
                              if (i > 0) const Divider(),
                              _MemberTile(member: member, members: data.members, isAdmin: isAdmin),
                            ],
                          ],
                        ),
                      ),
                      if (isAdmin && data.invitations.isNotEmpty) ...[
                        const SizedBox(height: FxSpace.lg),
                        Padding(
                          padding: const EdgeInsets.only(left: FxSpace.xs, bottom: FxSpace.sm),
                          child: Text(
                            l10n.pendingInvitations,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        Card(
                          child: Column(
                            children: [
                              for (final (i, invitation) in data.invitations.indexed) ...[
                                if (i > 0) const Divider(),
                                _InvitationTile(invitation: invitation),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _invite(BuildContext context, WidgetRef ref) async {
    final email = await showDialog<String>(context: context, builder: (_) => const _InviteDialog());
    if (email == null || !context.mounted) return;
    ref.invalidate(membersProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.invitationSent(email))),
    );
  }
}

/// Exécute une action d'administration, puis rafraîchit la liste ou affiche l'erreur.
Future<void> _runAction(
  BuildContext context,
  WidgetRef ref,
  Future<void> Function() action, {
  required String success,
  bool refreshSpace = false,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  try {
    await action();
    ref.invalidate(membersProvider);
    if (refreshSpace) ref.invalidate(userSpaceProvider);
    messenger.showSnackBar(SnackBar(content: Text(success)));
  } on AuthError catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.failure(e.failure))));
  }
}

class _MemberTile extends ConsumerWidget {
  const _MemberTile({required this.member, required this.members, required this.isAdmin});

  final Member member;
  final List<Member> members;
  final bool isAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final space = ref.watch(userSpaceProvider).value;
    final isMe = space?.profile.id == member.userId;
    final orgId = space?.membership?.organization.id;
    final soleAdmin = wouldLeaveNoAdmin(members, member, null);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: FxSpace.md, vertical: FxSpace.xs),
      leading: CircleAvatar(
        backgroundColor: FxColors.mint,
        foregroundColor: FxColors.petrol,
        child: Text(
          Profile(id: member.userId, email: member.email, fullName: member.fullName, locale: 'fr', isSuperadmin: false)
              .initials,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      title: Text(isMe ? '${member.displayName} (${l10n.youSuffix})' : member.displayName),
      subtitle: Text(
        soleAdmin ? '${member.email}\n${l10n.lastAdminHint}' : member.email,
        style: text.bodySmall?.copyWith(color: FxColors.inkSoft),
      ),
      isThreeLine: soleAdmin,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RolePill(member.role),
          if (isAdmin && orgId != null)
            PopupMenuButton<_MemberAction>(
              tooltip: l10n.memberActions(member.displayName),
              icon: const Icon(Icons.more_vert),
              itemBuilder: (_) => [
                PopupMenuItem(enabled: false, child: Text(l10n.changeRole, style: text.labelMedium)),
                for (final role in MemberRole.values)
                  CheckedPopupMenuItem(
                    value: _MemberAction.role(role),
                    checked: member.role == role,
                    enabled: member.role != role && !wouldLeaveNoAdmin(members, member, role),
                    child: Text(l10n.role(role)),
                  ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: const _MemberAction.remove(),
                  enabled: !soleAdmin,
                  child: Text(l10n.removeMember, style: const TextStyle(color: FxColors.error)),
                ),
              ],
              onSelected: (action) => _onAction(context, ref, orgId, isMe, action),
            ),
        ],
      ),
    );
  }

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    String orgId,
    bool isMe,
    _MemberAction action,
  ) async {
    final l10n = context.l10n;
    final repo = ref.read(membersRepositoryProvider);
    final role = action.role;
    if (role != null) {
      return _runAction(
        context,
        ref,
        () => repo.setRole(orgId, member.userId, role),
        success: l10n.roleChanged,
        refreshSpace: isMe,
      );
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.removeConfirmTitle(member.displayName)),
        content: Text(l10n.removeConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: FxColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.removeConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _runAction(
      context,
      ref,
      () => repo.remove(orgId, member.userId),
      success: l10n.memberRemoved,
      refreshSpace: isMe,
    );
  }
}

/// Action du menu d'un membre : changer de rôle (`role` renseigné) ou retirer.
class _MemberAction {
  const _MemberAction.role(MemberRole this.role);
  const _MemberAction.remove() : role = null;

  final MemberRole? role;

  @override
  bool operator ==(Object other) => other is _MemberAction && other.role == role;

  @override
  int get hashCode => role.hashCode;
}

class _InvitationTile extends ConsumerWidget {
  const _InvitationTile({required this.invitation});

  final Invitation invitation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final expired = invitation.isExpiredAt(DateTime.now());
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag())
        .add_Hm()
        .format(invitation.expiresAt);
    final orgId = ref.watch(userSpaceProvider).value?.membership?.organization.id;
    MembersRepository repo() => ref.read(membersRepositoryProvider);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: FxSpace.md, vertical: FxSpace.xs),
      leading: Icon(
        expired ? Icons.schedule : Icons.mark_email_unread_outlined,
        color: expired ? FxColors.warning : FxColors.emeraldInk,
      ),
      title: Text(invitation.email),
      subtitle: Text(
        '${l10n.role(invitation.role)} · ${expired ? l10n.invitationExpiredShort : l10n.invitationExpiresOn(date)}',
        style: text.bodySmall?.copyWith(color: expired ? FxColors.warning : FxColors.inkSoft),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (orgId != null)
            TextButton(
              onPressed: () => _runAction(
                context,
                ref,
                () => repo().invite(orgId, invitation.email, invitation.role),
                success: l10n.invitationSent(invitation.email),
              ),
              child: Text(l10n.resendInvitation),
            ),
          IconButton(
            tooltip: l10n.cancelInvitation,
            icon: const Icon(Icons.close),
            onPressed: () => _runAction(
              context,
              ref,
              () => repo().revokeInvitation(invitation.id),
              success: l10n.invitationCanceled,
            ),
          ),
        ],
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill(this.role);

  final MemberRole role;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (role) {
      MemberRole.admin => (FxColors.petrol, FxColors.white),
      MemberRole.editor => (FxColors.mintPale, FxColors.petrol),
      MemberRole.viewer => (FxColors.cloud, FxColors.inkSoft),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: role == MemberRole.viewer ? Border.all(color: FxColors.line) : null,
      ),
      child: Text(
        context.l10n.role(role),
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Invitation d'un membre avec choix du rôle. Renvoie l'e-mail invité.
class _InviteDialog extends ConsumerStatefulWidget {
  const _InviteDialog();

  @override
  ConsumerState<_InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends ConsumerState<_InviteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  MemberRole _role = MemberRole.editor;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final orgId = ref.read(userSpaceProvider).value?.membership?.organization.id;
    if (orgId == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final email = normalizeEmail(_email.text);
      await ref.read(membersRepositoryProvider).invite(orgId, email, _role);
      if (mounted) Navigator.of(context).pop(email);
    } on AuthError catch (e) {
      if (mounted) setState(() => _error = context.l10n.failure(e.failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.inviteDialogTitle),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EmailField(controller: _email, onSubmitted: (_) => _submit()),
                const SizedBox(height: FxSpace.md),
                Text(l10n.roleLabel, style: Theme.of(context).textTheme.titleSmall),
                RadioGroup<MemberRole>(
                  groupValue: _role,
                  onChanged: (r) => setState(() => _role = r ?? _role),
                  child: Column(
                    children: [
                      for (final role in MemberRole.values)
                        RadioListTile<MemberRole>(
                          value: role,
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.role(role)),
                          subtitle: Text(l10n.roleHelp(role)),
                        ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: FxSpace.sm),
                  MessageBanner.error(_error!),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        BusyButton(label: l10n.inviteSend, busy: _busy, onPressed: _submit),
      ],
    );
  }
}
