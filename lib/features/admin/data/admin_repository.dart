import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase.dart';
import '../../auth/data/auth_repository.dart';
import '../../session/domain/user_space.dart';

class PendingInvitation {
  const PendingInvitation({required this.email, required this.expiresAt});

  final String email;
  final DateTime expiresAt;

  bool get isExpired => expiresAt.isBefore(DateTime.now());
}

class AdminOrganization {
  const AdminOrganization({
    required this.organization,
    required this.memberCount,
    required this.createdAt,
    this.pendingInvitation,
  });

  final Organization organization;
  final int memberCount;
  final DateTime createdAt;

  /// Dernière invitation ni acceptée ni révoquée, s'il y en a une.
  final PendingInvitation? pendingInvitation;

  factory AdminOrganization.fromJson(Map<String, dynamic> json) {
    final counts = json['memberships'] as List<dynamic>? ?? const [];
    final invitations = (json['invitations'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .where((i) => i['accepted_at'] == null && i['revoked_at'] == null)
        .map((i) => PendingInvitation(
              email: i['email'] as String,
              expiresAt: DateTime.parse(i['expires_at'] as String).toLocal(),
            ))
        .toList()
      ..sort((a, b) => b.expiresAt.compareTo(a.expiresAt));
    return AdminOrganization(
      organization: Organization.fromJson(json),
      memberCount: counts.isEmpty ? 0 : (counts.first as Map<String, dynamic>)['count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      pendingInvitation: invitations.isEmpty ? null : invitations.first,
    );
  }
}

/// Offres et quota de scans mensuel par défaut (miroir de la table plans ; null = sur mesure).
const adminPlans = {'pilot': 300, 'essential': 1000, 'pro': 3000, 'custom': null};

/// Usage d'une organisation sur un mois (console super-admin).
class OrgUsage {
  const OrgUsage({
    required this.orgId,
    required this.plan,
    required this.scanQuota,
    this.scans = 0,
    this.members = 0,
    this.items = 0,
    this.inputTokens = 0,
    this.outputTokens = 0,
    this.costUsd = 0,
  });

  factory OrgUsage.fromJson(Map<String, dynamic> json) => OrgUsage(
        orgId: json['org_id'] as String,
        plan: json['plan'] as String,
        scanQuota: json['scan_quota'] as int,
        scans: json['scans'] as int? ?? 0,
        members: json['members'] as int? ?? 0,
        items: json['items'] as int? ?? 0,
        inputTokens: (json['input_tokens'] as num?)?.toInt() ?? 0,
        outputTokens: (json['output_tokens'] as num?)?.toInt() ?? 0,
        costUsd: (json['cost_usd'] as num?)?.toDouble() ?? 0,
      );

  final String orgId;
  final String plan;
  final int scanQuota;
  final int scans;
  final int members;

  /// Matières (atelier) ou références publiées (fournisseur).
  final int items;
  final int inputTokens;
  final int outputTokens;
  final double costUsd;
}

/// Tarif du modèle d'IA, en dollars par million de jetons.
class AiPricing {
  const AiPricing({required this.inputPerMtok, required this.outputPerMtok});

  final double inputPerMtok;
  final double outputPerMtok;
}

class AdminRepository {
  AdminRepository(this._client);

  final SupabaseClient _client;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      throw AuthError.from(e);
    }
  }

  Future<List<AdminOrganization>> listOrganizations() => _guard(() async {
        final rows = await _client
            .from('organizations')
            .select('id, name, kind, created_at, memberships(count), '
                'invitations(email, expires_at, accepted_at, revoked_at)')
            .order('created_at', ascending: false);
        return rows.map(AdminOrganization.fromJson).toList();
      });

  Future<Map<String, dynamic>> _call(Map<String, dynamic> body) async {
    final response = await _client.functions.invoke('admin-users', body: body);
    return (response.data as Map).cast<String, dynamic>();
  }

  /// Crée l'organisation (atelier ou fournisseur) puis invite son premier admin. Si l'invitation échoue,
  /// l'atelier existe : l'invitation peut être renvoyée depuis la console.
  Future<void> createOrganizationWithAdmin({
    required String name,
    required String adminEmail,
    OrgKind kind = OrgKind.atelier,
  }) =>
      _guard(() async {
        final created = await _call({
          'action': 'create_organization',
          'name': name,
          'kind': kind.name,
        });
        final orgId = (created['organization'] as Map)['id'] as String;
        await _call({
          'action': 'invite',
          'orgId': orgId,
          'email': adminEmail,
          'role': MemberRole.admin.name,
        });
      });

  Future<void> invite({required String orgId, required String email, required MemberRole role}) =>
      _guard(() => _call({'action': 'invite', 'orgId': orgId, 'email': email, 'role': role.name}));

  /// Usage du mois [month] (premier jour du mois), par organisation.
  Future<List<OrgUsage>> usage(DateTime month) => _guard(() async {
        final day = '${month.year}-${month.month.toString().padLeft(2, '0')}-01';
        final rows = await _client.rpc<List<dynamic>>('admin_usage', params: {'p_month': day});
        return rows.cast<Map<String, dynamic>>().map(OrgUsage.fromJson).toList();
      });

  /// Offre et quota (null : quota par défaut de l'offre). Effet immédiat sur le scanner.
  Future<void> setPlan(String orgId, String plan, int? quota) => _guard(
        () => _client.rpc<dynamic>('admin_set_plan', params: {'p_org': orgId, 'p_plan': plan, 'p_quota': quota}),
      );

  Future<AiPricing> pricing() => _guard(() async {
        final row = await _client.from('platform_settings').select('ai_input_usd_per_mtok, ai_output_usd_per_mtok').single();
        return AiPricing(
          inputPerMtok: (row['ai_input_usd_per_mtok'] as num).toDouble(),
          outputPerMtok: (row['ai_output_usd_per_mtok'] as num).toDouble(),
        );
      });

  Future<void> setPricing(AiPricing p) => _guard(() => _client
      .from('platform_settings')
      .update({'ai_input_usd_per_mtok': p.inputPerMtok, 'ai_output_usd_per_mtok': p.outputPerMtok})
      .eq('id', true));
}

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(ref.watch(supabaseProvider)),
);

final adminOrganizationsProvider = FutureProvider<List<AdminOrganization>>(
  (ref) => ref.watch(adminRepositoryProvider).listOrganizations(),
);

/// Mois affiché dans la console (premier jour du mois).
class AdminMonth extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void shift(int months) => state = DateTime(state.year, state.month + months);
}

final adminMonthProvider = NotifierProvider<AdminMonth, DateTime>(AdminMonth.new);

final adminUsageProvider = FutureProvider<Map<String, OrgUsage>>((ref) async {
  final list = await ref.watch(adminRepositoryProvider).usage(ref.watch(adminMonthProvider));
  return {for (final u in list) u.orgId: u};
});

final aiPricingProvider = FutureProvider<AiPricing>((ref) => ref.watch(adminRepositoryProvider).pricing());
