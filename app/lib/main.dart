import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application/auth_provider.dart';
import 'application/category_theme_provider.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/login/login_screen.dart';
import 'presentation/shell/app_shell.dart';

void main() {
  runApp(const ProviderScope(child: CeylonReviewApp()));
}

class CeylonReviewApp extends ConsumerWidget {
  const CeylonReviewApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(activeCategoryProvider);
    final themeMode = ref.watch(themeModeProvider);
    final signedIn = ref.watch(authProvider) != null;

    return MaterialApp(
      title: 'Ceylon Review',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.of(category, Brightness.light),
      darkTheme: AppTheme.of(category, Brightness.dark),
      themeMode: themeMode,
      // 360ms category cross-fade — the signature interaction.
      themeAnimationDuration: AppMotion.slow,
      themeAnimationCurve: Curves.easeInOut,
      home: signedIn ? const AppShell() : const LoginScreen(),
    );
  }
}
