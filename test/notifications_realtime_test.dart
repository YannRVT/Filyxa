// Phase 24 : notifications en temps réel.
import 'package:filyxa/features/reports/data/reports_repository.dart';
import 'package:filyxa/features/reports/domain/error_report.dart';
import 'package:filyxa/features/session/data/user_space_repository.dart';
import 'package:filyxa/features/session/domain/user_space.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeReports implements ReportsRepository {
  var fetches = 0;
  var unread = 0;
  String? watchedUser;
  void Function()? push;
  var stopped = false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<AppNotification>> notifications() async {
    fetches++;
    return [
      for (var i = 0; i < unread; i++)
        AppNotification(id: 'n$i', kind: NotificationKind.stockOut, createdAt: DateTime(2026, 11, 12)),
    ];
  }

  @override
  void Function() watchNotifications(String userId, {required void Function() onChange}) {
    watchedUser = userId;
    push = onChange;
    return () => stopped = true;
  }
}

void main() {
  test('une notification reçue en temps réel met la cloche à jour, sans attendre', () async {
    final repo = _FakeReports();
    final container = ProviderContainer(overrides: [
      reportsRepositoryProvider.overrideWithValue(repo),
      userSpaceProvider.overrideWith((ref) async => const UserSpace(
            profile: Profile(id: 'claire', email: 'c@a.fr', locale: 'fr', isSuperadmin: false),
            membership: Membership(
              organization: Organization(id: 'org', name: 'Atelier', kind: OrgKind.atelier),
              role: MemberRole.editor,
            ),
          )),
    ]);
    addTearDown(container.dispose);
    await container.read(userSpaceProvider.future);
    final sub = container.listen(unreadNotificationsProvider, (_, _) {});
    await container.read(notificationsProvider.future);
    expect(repo.watchedUser, 'claire', reason: 'abonnement aux seules notifications de l\'utilisateur');
    expect(sub.read(), 0);

    repo.unread = 1;
    repo.push!();
    await container.read(notificationsProvider.future);
    expect(repo.fetches, 2);
    expect(sub.read(), 1);

    container.dispose();
    expect(repo.stopped, isTrue, reason: 'l\'abonnement s\'arrête avec la session');
  });
}
