import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/locale.dart';
import '../../app/theme.dart';
import '../../l10n/l10n.dart';
import '../auth/data/auth_repository.dart';
import '../session/data/user_space_repository.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final space = ref.watch(userSpaceProvider).value;
    final current = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountTitle)),
      body: ListView(
        padding: const EdgeInsets.all(FxSpace.md),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (space != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(FxSpace.md),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: FxColors.mint,
                              foregroundColor: FxColors.petrol,
                              child: Text(
                                space.profile.initials,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: FxSpace.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(space.profile.displayName, style: text.titleMedium),
                                  Text(
                                    space.profile.email,
                                    style: text.bodyMedium?.copyWith(color: FxColors.inkSoft),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: FxSpace.md),
                  Card(
                    child: Column(
                      children: [
                        if (space?.membership != null) ...[
                          ListTile(
                            title: Text(l10n.organizationLabel),
                            subtitle: Text(space!.membership!.organization.name),
                            leading: const Icon(Icons.storefront_outlined),
                          ),
                          const Divider(),
                          ListTile(
                            title: Text(l10n.roleLabel),
                            subtitle: Text(l10n.role(space.membership!.role)),
                            leading: const Icon(Icons.badge_outlined),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.group_outlined),
                            title: Text(l10n.membersEntry),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.go('/account/members'),
                          ),
                          const Divider(),
                        ],
                        ListTile(
                          leading: const Icon(Icons.translate),
                          title: Text(l10n.languageLabel),
                          trailing: DropdownButton<String>(
                            value: supportedLanguages.containsKey(current) ? current : 'fr',
                            underline: const SizedBox.shrink(),
                            items: [
                              for (final entry in supportedLanguages.entries)
                                DropdownMenuItem(value: entry.key, child: Text(entry.value)),
                            ],
                            onChanged: (code) {
                              if (code != null) ref.read(localeProvider.notifier).select(code);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (space?.profile.isSuperadmin ?? false) ...[
                    const SizedBox(height: FxSpace.md),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.admin_panel_settings_outlined),
                        title: Text(l10n.superadminConsole),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go('/admin'),
                      ),
                    ),
                  ],
                  const SizedBox(height: FxSpace.lg),
                  OutlinedButton.icon(
                    onPressed: () => ref.read(authRepositoryProvider).signOut(),
                    icon: const Icon(Icons.logout),
                    label: Text(l10n.logout),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
