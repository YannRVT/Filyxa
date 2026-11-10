import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../data/auth_repository.dart';
import '../domain/auth_rules.dart';

/// Mot de passe oublié en deux étapes : envoi d'un code, puis code + nouveau mot de passe.
class ResetScreen extends ConsumerStatefulWidget {
  const ResetScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  ConsumerState<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends ConsumerState<ResetScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.initialEmail);
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _codeSent = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_email, _code, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on AuthError catch (e) {
      if (mounted) setState(() => _error = context.l10n.failure(e.failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendCode() async {
    final e = checkEmail(_email.text);
    if (e != null) {
      setState(() => _error = context.l10n.fieldError(e));
      return;
    }
    await _run(() async {
      await ref.read(authRepositoryProvider).sendRecoveryCode(_email.text);
      if (mounted) setState(() => _codeSent = true);
    });
  }

  Future<void> _reset() async {
    if (!_formKey.currentState!.validate()) return;
    await _run(() async {
      await ref
          .read(authRepositoryProvider)
          .resetPassword(_email.text, _code.text, _password.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.passwordChanged)),
      );
      context.go('/library');
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthScaffold(
      onBack: _busy ? null : () => context.go('/login'),
      children: [
        AuthHeader(
          title: l10n.resetTitle,
          subtitle: _codeSent ? l10n.resetCodeSent(normalizeEmail(_email.text)) : l10n.resetIntro,
        ),
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EmailField(controller: _email, enabled: !_codeSent),
                if (_codeSent) ...[
                  const SizedBox(height: FxSpace.md),
                  CodeField(controller: _code),
                  const SizedBox(height: FxSpace.md),
                  PasswordField(
                    controller: _password,
                    label: l10n.newPasswordLabel,
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
                    onSubmitted: (_) => _reset(),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: FxSpace.lg),
        if (_error != null) ...[MessageBanner.error(_error!), const SizedBox(height: FxSpace.md)],
        BusyButton(
          label: _codeSent ? l10n.resetButton : l10n.sendCode,
          busy: _busy,
          onPressed: _codeSent ? _reset : _sendCode,
        ),
        if (_codeSent)
          TextButton(onPressed: _busy ? null : _sendCode, child: Text(l10n.resendCode)),
      ],
    );
  }
}
