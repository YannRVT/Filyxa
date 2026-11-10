import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../auth/data/auth_repository.dart';
import '../data/user_space_repository.dart';

/// Chargement de l'espace après connexion, avec reprise en cas d'erreur.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final space = ref.watch(userSpaceProvider);
    if (!space.hasError) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return AuthScaffold(
      children: [
        MessageBanner.error(l10n.loadingError),
        const SizedBox(height: FxSpace.lg),
        FilledButton(
          onPressed: () => ref.invalidate(userSpaceProvider),
          child: Text(l10n.retry),
        ),
        const SizedBox(height: FxSpace.sm),
        TextButton(
          onPressed: () => ref.read(authRepositoryProvider).signOut(),
          child: Text(l10n.logout),
        ),
      ],
    );
  }
}

/// Compte connecté mais rattaché à aucune organisation.
class NoOrganizationScreen extends ConsumerWidget {
  const NoOrganizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AuthScaffold(
      children: [
        AuthHeader(title: l10n.noOrgTitle, subtitle: l10n.noOrgBody),
        OutlinedButton(
          onPressed: () => ref.read(authRepositoryProvider).signOut(),
          child: Text(l10n.logout),
        ),
      ],
    );
  }
}
