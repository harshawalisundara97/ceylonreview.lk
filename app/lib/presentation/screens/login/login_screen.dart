import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/repositories/auth_repository.dart';

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
    final controller = TextEditingController(text: _email.text);
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset your password'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(labelText: 'Email'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Send reset link'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (email == null || email.trim().isEmpty || !mounted) return;
    await ref.read(authProvider.notifier).sendPasswordResetEmail(email);
    if (mounted) {
      _showMessage(
          'If an account exists for that email, a reset link is on its way.');
    }
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
        _showMessage('Account created! Check your email to confirm, '
            'then sign in.');
        setState(() => _creatingAccount = false);
      }
    } on AuthFailure catch (e) {
      if (mounted) _showMessage(e.message);
    } catch (_) {
      if (mounted) {
        _showMessage('Something went wrong. Check your connection '
            'and try again.');
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
        child: Center(
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
                    'Ceylon Review',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displayMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Places you\'ll love, across the island',
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
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter your name'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Enter a valid email'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Password must be at least 6 characters'
                        : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  if (!_creatingAccount) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _busy ? null : _showForgotPasswordDialog,
                        child: const Text('Forgot password?'),
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
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_creatingAccount ? 'Create account' : 'Explore'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(
                            () => _creatingAccount = !_creatingAccount),
                    child: Text(_creatingAccount
                        ? 'Already have an account? Sign in'
                        : 'New here? Create an account'),
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
