import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/env.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../data/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn({String? email, String? password}) async {
    if (email == null && !_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(email ?? _email.text, password ?? _password.text);
      // La redirection est faite par le routeur à l'ouverture de la session.
    } on AuthError catch (e) {
      if (mounted) setState(() => _error = context.l10n.failure(e.failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthScaffold(
      children: [
        AuthHeader(title: l10n.loginTitle, subtitle: l10n.loginSubtitle),
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EmailField(controller: _email),
                const SizedBox(height: FxSpace.md),
                PasswordField(
                  controller: _password,
                  label: l10n.passwordLabel,
                  validator: (v) => (v == null || v.isEmpty) ? l10n.errorPasswordShort : null,
                  onSubmitted: (_) => _signIn(),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _busy ? null : () => context.go('/reset', extra: _email.text),
            child: Text(l10n.forgotPassword),
          ),
        ),
        if (_error != null) ...[
          MessageBanner.error(_error!),
          const SizedBox(height: FxSpace.md),
        ],
        BusyButton(label: l10n.loginButton, busy: _busy, onPressed: _signIn),
        const SizedBox(height: FxSpace.md),
        const Divider(),
        const SizedBox(height: FxSpace.sm),
        OutlinedButton.icon(
          onPressed: _busy ? null : () => context.go('/invite'),
          icon: const Icon(Icons.mark_email_unread_outlined),
          label: Text(l10n.haveInvitation),
        ),
        if (Env.hasQuickLogin) ...[
          const SizedBox(height: FxSpace.sm),
          TextButton(
            onPressed: _busy
                ? null
                : () => _signIn(email: Env.devEmail, password: Env.devPassword),
            child: Text(l10n.devQuickLogin),
          ),
        ],
      ],
    );
  }
}
