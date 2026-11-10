import 'package:filyxa/features/members/data/members_repository.dart';
import 'package:filyxa/features/members/domain/member.dart';
import 'package:filyxa/features/members/ui/members_screen.dart';
import 'package:filyxa/features/session/data/user_space_repository.dart';
import 'package:filyxa/features/session/domain/user_space.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

final _joined = DateTime(2026, 11, 1);
final _claire = Member(userId: 'u1', email: 'claire@atelier.fr', fullName: 'Claire Martin', role: MemberRole.admin, joinedAt: _joined);
final _hugo = Member(userId: 'u2', email: 'hugo@atelier.fr', fullName: 'Hugo Bernard', role: MemberRole.editor, joinedAt: _joined);
final _lea = Member(userId: 'u3', email: 'lea@atelier.fr', fullName: 'Léa Dubois', role: MemberRole.viewer, joinedAt: _joined);

UserSpace _space(Member me) => UserSpace(
      profile: Profile(id: me.userId, email: me.email, fullName: me.fullName, locale: 'fr', isSuperadmin: false),
      membership: Membership(
        organization: const Organization(id: 'org', name: 'Atelier Démo', kind: OrgKind.atelier),
        role: me.role,
      ),
    );

Widget _app(Member me, {List<Invitation> invitations = const []}) => ProviderScope(
      overrides: [
        userSpaceProvider.overrideWith((ref) async => _space(me)),
        membersProvider.overrideWith(
          (ref) async => MembersOverview(members: sortMembers([_lea, _hugo, _claire]), invitations: invitations),
        ),
      ],
      child: const MaterialApp(
        locale: Locale('fr'),
        localizationsDelegates: [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: AppLocalizations.supportedLocales,
        home: MembersScreen(),
      ),
    );

void main() {
  group('règles', () {
    test('tri : Admin, Éditeur, Lecteur', () {
      expect(sortMembers([_lea, _hugo, _claire]).map((m) => m.userId), ['u1', 'u2', 'u3']);
    });

    test('le dernier admin ne peut être ni rétrogradé ni retiré', () {
      final members = [_claire, _hugo, _lea];
      expect(wouldLeaveNoAdmin(members, _claire, MemberRole.editor), isTrue);
      expect(wouldLeaveNoAdmin(members, _claire, null), isTrue);
      expect(wouldLeaveNoAdmin(members, _hugo, null), isFalse);
      final twoAdmins = [_claire, Member(userId: 'u4', email: 'b@a.fr', role: MemberRole.admin, joinedAt: _joined)];
      expect(wouldLeaveNoAdmin(twoAdmins, _claire, null), isFalse);
    });
  });

  testWidgets('Admin : invite, gère les rôles et les invitations', (tester) async {
    final invitation = Invitation(
      id: 'i1',
      email: 'nina@atelier.fr',
      role: MemberRole.editor,
      expiresAt: DateTime.now().add(const Duration(hours: 30)),
    );
    await tester.pumpWidget(_app(_claire, invitations: [invitation]));
    await tester.pumpAndSettle();

    expect(find.text('Claire Martin (vous)'), findsOneWidget);
    expect(find.text('Inviter'), findsOneWidget);
    expect(find.byTooltip('Actions pour Hugo Bernard'), findsOneWidget);
    expect(find.text('Invitations en attente'), findsOneWidget);
    expect(find.text('nina@atelier.fr'), findsOneWidget);
    expect(find.textContaining('Seul admin de l\'atelier'), findsOneWidget);

    // Le seul admin ne peut pas se retirer.
    await tester.tap(find.byTooltip('Actions pour Claire Martin'));
    await tester.pumpAndSettle();
    final remove = tester.widget<PopupMenuItem<Object?>>(
      find.ancestor(of: find.text('Retirer de l\'atelier'), matching: find.byWidgetPredicate((w) => w is PopupMenuItem)),
    );
    expect(remove.enabled, isFalse);
  });

  testWidgets('Admin : la fenêtre d\'invitation propose les 3 rôles, Éditeur par défaut', (tester) async {
    await tester.pumpWidget(_app(_claire));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inviter'));
    await tester.pumpAndSettle();

    expect(find.text('Inviter un membre'), findsOneWidget);
    expect(find.text('Consulte et exporte, sans rien modifier'), findsOneWidget);
    final editor = tester.widget<RadioListTile<MemberRole>>(
      find.widgetWithText(RadioListTile<MemberRole>, 'Éditeur'),
    );
    final group = tester.widget<RadioGroup<MemberRole>>(find.byType(RadioGroup<MemberRole>));
    expect(group.groupValue, editor.value);
  });

  for (final me in [_hugo, _lea]) {
    testWidgets('${me.role.name} : consulte la liste sans aucune action', (tester) async {
      await tester.pumpWidget(_app(me));
      await tester.pumpAndSettle();

      expect(find.text('Claire Martin'), findsOneWidget);
      expect(find.text('Inviter'), findsNothing);
      expect(find.byIcon(Icons.more_vert), findsNothing);
      expect(find.text('Invitations en attente'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('pas de débordement sur téléphone', (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(_claire));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
