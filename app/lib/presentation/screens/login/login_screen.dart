import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../core/l10n_ext.dart';
import '../../widgets/language_picker.dart';

/// Email + password auth against the real backend, with a toggle between
/// signing in and creating an account.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _creatingAccount = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _showForgotPasswordDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => _ForgotPasswordDialog(initialEmail: _email.text),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final auth = ref.read(authProvider.notifier);
    try {
      if (_creatingAccount) {
        await auth.signUp(
          name: _name.text,
          email: _email.text,
          password: _password.text,
        );
      } else {
        await auth.signIn(email: _email.text, password: _password.text);
      }
    } on EmailConfirmationRequired {
      if (mounted) {
        _showMessage(context.l10n.accountCreatedCheckEmail);
        setState(() => _creatingAccount = false);
      }
    } on AuthFailure catch (e) {
      if (mounted) _showMessage(e.message);
    } catch (_) {
      if (mounted) {
        _showMessage(context.l10n.genericConnectionError);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: IconButton(
                  tooltip: context.l10n.language,
                  icon: const Icon(Icons.language_rounded),
                  onPressed: () => showLanguagePicker(context),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo mark: pin + brand name.
                      Icon(Icons.location_pin,
                          size: 64, color: AppColors.ceylonGreen),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        context.l10n.appTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displayMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        context.l10n.tagline,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      if (_creatingAccount) ...[
                        TextFormField(
                          controller: _name,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [AutofillHints.name],
                          decoration: InputDecoration(labelText: context.l10n.name),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? context.l10n.enterYourName
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: InputDecoration(labelText: context.l10n.email),
                        validator: (v) => (v == null || !v.contains('@'))
                            ? context.l10n.enterValidEmail
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextFormField(
                        controller: _password,
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                        decoration:
                            InputDecoration(labelText: context.l10n.password),
                        validator: (v) => (v == null || v.length < 6)
                            ? context.l10n.passwordMin6
                            : null,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      if (!_creatingAccount) ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _busy ? null : _showForgotPasswordDialog,
                            child: Text(context.l10n.forgotPassword),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      FilledButton(
                        onPressed: _busy ? null : _submit,
                        child: _busy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(_creatingAccount
                                ? context.l10n.createAccount
                                : context.l10n.explore),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => setState(
                                () => _creatingAccount = !_creatingAccount),
                        child: Text(_creatingAccount
                            ? context.l10n.alreadyHaveAccountSignIn
                            : context.l10n.newHereCreateAccount),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal that collects an email and sends a password-reset link, with its
/// own validation, loading state, and error handling.
class _ForgotPasswordDialog extends ConsumerStatefulWidget {
  const _ForgotPasswordDialog({required this.initialEmail});

  final String initialEmail;

  @override
  ConsumerState<_ForgotPasswordDialog> createState() =>
      _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<_ForgotPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.initialEmail);
  bool _busy = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref.read(authProvider.notifier).sendPasswordResetEmail(_email.text);
      if (mounted) setState(() => _sent = true);
    } on AuthFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
              content: Text(context.l10n.genericConnectionError)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      return AlertDialog(
        title: Text(context.l10n.checkYourEmail),
        content: Text(
            context.l10n.resetLinkSent(_emailText)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.done),
          ),
        ],
      );
    }
    return AlertDialog(
      title: Text(context.l10n.resetYourPassword),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: InputDecoration(labelText: context.l10n.email),
          autofocus: true,
          enabled: !_busy,
          validator: (v) =>
              (v == null || !v.contains('@')) ? context.l10n.enterValidEmail : null,
          onFieldSubmitted: (_) => _send(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _send,
          child: _busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.l10n.sendResetLink),
        ),
      ],
    );
  }

  String get _emailText => _email.text.trim();
}
