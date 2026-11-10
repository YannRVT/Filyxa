import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../session/data/user_space_repository.dart';
import '../data/auth_repository.dart';
import '../domain/auth_rules.dart';

enum _Step { code, password, expired }

/// Rejoindre une organisation : e-mail + code à 6 chiffres, puis choix du mot de passe.
class InviteScreen extends ConsumerStatefulWidget {
  const InviteScreen({super.key});

  @override
  ConsumerState<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends ConsumerState<InviteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  _Step _step = _Step.code;
  bool _busy = false;
  String? _error;
  String? _info;
  String? _organizationName;

  @override
  void dispose() {
    for (final c in [_email, _code, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    try {
      await action();
    } on AuthError catch (e) {
      if (!mounted) return;
      if (e.failure == AuthFailure.invitationExpired) {
        await _repo.signOut();
        if (mounted) setState(() => _step = _Step.expired);
      } else {
        if (e.failure == AuthFailure.invitationNotFound || e.failure == AuthFailure.alreadyMember) {
          await _repo.signOut();
        }
        if (mounted) setState(() => _error = context.l10n.failure(e.failure));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    await _run(() async {
      await _repo.verifyInvitationCode(_email.text, _code.text);
      await _repo.acceptInvitation();
      final space = await ref.refresh(userSpaceProvider.future);
      if (!mounted) return;
      setState(() {
        _organizationName = space?.membership?.organization.name;
        _step = _Step.password;
      });
    });
  }

  Future<void> _resend() async {
    final e = checkEmail(_email.text);
    if (e != null) {
      setState(() => _error = context.l10n.fieldError(e));
      return;
    }
    await _run(() async {
      await _repo.resendInvitationCode(_email.text);
      if (mounted) setState(() => _info = context.l10n.codeResent(normalizeEmail(_email.text)));
    });
  }

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) return;
    await _run(() async {
      await _repo.setPassword(_password.text);
      if (mounted) context.go('/library');
    });
  }

  Future<void> _backToLogin() async {
    if (_step == _Step.password) await _repo.signOut();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthScaffold(
      onBack: _busy ? null : _backToLogin,
      children: switch (_step) {
        _Step.code => _codeStep(l10n),
        _Step.password => _passwordStep(l10n),
        _Step.expired => _expiredStep(l10n),
      },
    );
  }

  List<Widget> _messages() => [
        if (_error != null) ...[MessageBanner.error(_error!), const SizedBox(height: FxSpace.md)],
        if (_info != null) ...[MessageBanner.info(_info!), const SizedBox(height: FxSpace.md)],
      ];

  List<Widget> _codeStep(AppLocalizations l10n) => [
        AuthHeader(title: l10n.inviteTitle, subtitle: l10n.inviteIntro),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EmailField(controller: _email),
              const SizedBox(height: FxSpace.md),
              CodeField(controller: _code, onSubmitted: (_) => _verify()),
            ],
          ),
        ),
        const SizedBox(height: FxSpace.lg),
        ..._messages(),
        BusyButton(label: l10n.verifyCode, busy: _busy, onPressed: _verify),
        const SizedBox(height: FxSpace.sm),
        TextButton(onPressed: _busy ? null : _resend, child: Text(l10n.resendCode)),
      ];

  List<Widget> _passwordStep(AppLocalizations l10n) => [
        AuthHeader(
          title: l10n.choosePasswordTitle,
          subtitle: l10n.choosePasswordIntro(_organizationName ?? 'Filyxa'),
        ),
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PasswordField(
                  controller: _password,
                  label: l10n.passwordLabel,
                  helperText: l10n.passwordHelper,
                  newPassword: true,
                  validator: (v) {
                    final e = checkPassword(v);
                    return e == null ? null : l10n.fieldError(e);
                  },
                ),
                const SizedBox(height: FxSpace.md),
                PasswordField(
                  controller: _confirm,
                  label: l10n.confirmPasswordLabel,
                  newPassword: true,
                  validator: (v) {
                    final e = checkConfirmation(v, _password.text);
                    return e == null ? null : l10n.fieldError(e);
                  },
                  onSubmitted: (_) => _savePassword(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: FxSpace.lg),
        ..._messages(),
        BusyButton(label: l10n.savePassword, busy: _busy, onPressed: _savePassword),
      ];

  List<Widget> _expiredStep(AppLocalizations l10n) => [
        AuthHeader(title: l10n.invitationExpiredTitle),
        MessageBanner.error(l10n.invitationExpiredBody),
        const SizedBox(height: FxSpace.lg),
        FilledButton(onPressed: () => context.go('/login'), child: Text(l10n.backToLogin)),
      ];
}
