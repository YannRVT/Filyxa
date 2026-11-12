import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../auth/data/auth_repository.dart';
import '../../library/domain/material.dart' show formatNumber, parseNumber;
import '../../library/ui/material_widgets.dart' show langOf;
import '../../members/data/members_repository.dart' show currentRoleProvider;
import '../../session/data/user_space_repository.dart';
import '../../session/domain/user_space.dart';
import '../data/studio_repository.dart';
import 'planning_widgets.dart' show ProLockedNote;

/// Compte › Réglages de l'atelier : coefficient minimal (Admin, offre Pro).
class WorkspaceScreen extends ConsumerStatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  ConsumerState<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends ConsumerState<WorkspaceScreen> {
  TextEditingController? _coef;
  bool _busy = false;
  String? _error;
  String? _saved;

  @override
  void dispose() {
    _coef?.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final value = parseNumber(_coef!.text);
    if (value == null || value < 1 || value > 20) {
      setState(() => _error = l10n.errorNumberRange(1, 20));
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _saved = null;
    });
    try {
      final orgId = (await ref.read(userSpaceProvider.future))?.membership?.organization.id;
      if (orgId == null) return;
      await ref.read(studioRepositoryProvider).setMinCoefficient(orgId, value);
      ref.invalidate(minCoefficientProvider);
      if (mounted) setState(() => _saved = l10n.workspaceSaved);
    } on AuthError catch (e) {
      if (mounted) setState(() => _error = l10n.failure(e.failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final pro = ref.watch(hasProProvider).value ?? false;
    final isAdmin = ref.watch(currentRoleProvider)?.atLeast(MemberRole.admin) ?? false;
    final min = ref.watch(minCoefficientProvider);
    if (min.hasValue && _coef == null) {
      _coef = TextEditingController(text: formatNumber(min.value!, langOf(context), decimals: 2));
    }
    final canEdit = pro && isAdmin;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workspaceTitle),
        leading: BackButton(onPressed: () => context.go('/account')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(FxSpace.md),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(FxSpace.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.minCoefficientLabel, style: text.titleSmall),
                      Text(l10n.minCoefficientHelp, style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
                      const SizedBox(height: FxSpace.md),
                      if (!pro) ...[const ProLockedNote(), const SizedBox(height: FxSpace.sm)],
                      if (_coef == null)
                        const Center(child: CircularProgressIndicator())
                      else
                        TextField(
                          key: const ValueKey('min-coef'),
                          controller: _coef,
                          enabled: canEdit,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                          decoration: InputDecoration(labelText: l10n.minCoefficientLabel),
                        ),
                      if (canEdit) ...[
                        const SizedBox(height: FxSpace.md),
                        FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.save)),
                      ],
                      if (_error != null) ...[const SizedBox(height: FxSpace.sm), MessageBanner.error(_error!)],
                      if (_saved != null) ...[const SizedBox(height: FxSpace.sm), MessageBanner.success(_saved!)],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
