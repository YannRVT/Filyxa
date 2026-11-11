import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../features/auth/domain/auth_rules.dart';
import '../../l10n/l10n.dart';

/// Mise en page des écrans d'accès : logo, carte centrée, largeur bornée.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.children, this.onBack});

  final List<Widget> children;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: onBack == null ? null : AppBar(leading: BackButton(onPressed: onBack)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(FxSpace.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/brand/filyxa-logo.png',
                      height: 48,
                      semanticLabel: 'Filyxa',
                    ),
                  ),
                  const SizedBox(height: FxSpace.lg),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(FxSpace.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: text.titleLarge),
        if (subtitle != null) ...[
          const SizedBox(height: FxSpace.sm),
          Text(subtitle!, style: text.bodyMedium?.copyWith(color: FxColors.inkSoft)),
        ],
        const SizedBox(height: FxSpace.lg),
      ],
    );
  }
}

class EmailField extends StatelessWidget {
  const EmailField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.onSubmitted,
    this.label,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      autocorrect: false,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(labelText: label ?? l10n.emailLabel),
      validator: (v) {
        final e = checkEmail(v);
        return e == null ? null : l10n.fieldError(e);
      },
      onFieldSubmitted: onSubmitted,
    );
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.helperText,
    this.validator,
    this.onSubmitted,
    this.newPassword = false,
  });

  final TextEditingController controller;
  final String label;
  final String? helperText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;
  final bool newPassword;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      autofillHints: [widget.newPassword ? AutofillHints.newPassword : AutofillHints.password],
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.helperText,
        helperMaxLines: 2,
        suffixIcon: IconButton(
          tooltip: _obscure ? l10n.showPassword : l10n.hidePassword,
          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      validator: widget.validator,
      onFieldSubmitted: widget.onSubmitted,
    );
  }
}

/// Saisie du code à 6 chiffres, en police d'étiquette technique.
class CodeField extends StatelessWidget {
  const CodeField({super.key, required this.controller, this.onSubmitted});

  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      autofillHints: const [AutofillHints.oneTimeCode],
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(kCodeLength),
      ],
      style: FxTheme.mono(size: 22, weight: FontWeight.w500).copyWith(letterSpacing: 6),
      decoration: InputDecoration(labelText: l10n.codeLabel),
      validator: (v) {
        final e = checkCode(v);
        return e == null ? null : l10n.fieldError(e);
      },
      onFieldSubmitted: onSubmitted,
    );
  }
}

/// Bouton principal qui affiche une roue pendant l'action.
class BusyButton extends StatelessWidget {
  const BusyButton({super.key, required this.label, required this.busy, required this.onPressed});

  final String label;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: busy ? null : onPressed,
      child: busy
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: FxColors.white),
            )
          : Text(label),
    );
  }
}

/// Message d'erreur ou d'information dans un bandeau coloré à liseré.
class MessageBanner extends StatelessWidget {
  const MessageBanner.error(this.message, {super.key})
      : color = FxColors.error,
        background = FxColors.errorBg;

  const MessageBanner.info(this.message, {super.key})
      : color = FxColors.info,
        background = FxColors.infoBg;

  const MessageBanner.warning(this.message, {super.key})
      : color = FxColors.warning,
        background = FxColors.warningBg;

  const MessageBanner.success(this.message, {super.key})
      : color = FxColors.success,
        background = FxColors.successBg;

  final String message;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(FxRadius.md),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Text(message, style: const TextStyle(color: FxColors.ink, fontSize: 14)),
      ),
    );
  }
}
