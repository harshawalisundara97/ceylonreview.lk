import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/repositories/auth_repository.dart';

/// Shown after the user follows a password-reset email link, which
/// establishes a temporary recovery session. Lets them set a new password
/// to finish the reset.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.onDone});

  /// Called once the password has been updated successfully.
  final VoidCallback onDone;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final auth = ref.read(authProvider.notifier);
      await auth.updatePassword(_password.text);
      // The recovery session is already a real, signed-in session — sync
      // authProvider so the app treats the user as signed in immediately,
      // instead of bouncing them to the login screen to sign in again.
      auth.refresh();
      if (mounted) widget.onDone();
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
          ..showSnackBar(const SnackBar(
              content: Text('Could not update your password. Try again.')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    await ref.read(authProvider.notifier).signOut();
    if (mounted) widget.onDone();
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
                  Icon(Icons.lock_reset_rounded,
                      size: 64, color: AppColors.ceylonGreen),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Set a new password',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration:
                        const InputDecoration(labelText: 'New password'),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Password must be at least 6 characters'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _confirm,
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration:
                        const InputDecoration(labelText: 'Confirm password'),
                    validator: (v) => v != _password.text
                        ? 'Passwords don\'t match'
                        : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Update password'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: _busy ? null : _cancel,
                    child: const Text('Cancel'),
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
