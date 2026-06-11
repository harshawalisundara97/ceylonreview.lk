import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'application/auth_provider.dart';
import 'application/category_theme_provider.dart';
import 'core/supabase_config.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/login/login_screen.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/shell/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Restores any persisted auth session before the first frame.
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );
  runApp(const ProviderScope(child: CeylonReviewApp()));
}

class CeylonReviewApp extends ConsumerStatefulWidget {
  const CeylonReviewApp({super.key});

  @override
  ConsumerState<CeylonReviewApp> createState() => _CeylonReviewAppState();
}

class _CeylonReviewAppState extends ConsumerState<CeylonReviewApp> {
  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    final category = ref.watch(activeCategoryProvider);
    final themeMode = ref.watch(themeModeProvider);
    final signedIn = ref.watch(authProvider) != null;

    final Widget home = !_splashDone
        ? SplashScreen(onFinished: () => setState(() => _splashDone = true))
        : signedIn
            ? const AppShell()
            : const LoginScreen();

    return MaterialApp(
      title: 'Ceylon Review',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.of(category, Brightness.light),
      darkTheme: AppTheme.of(category, Brightness.dark),
      themeMode: themeMode,
      // 360ms category cross-fade — the signature interaction.
      themeAnimationDuration: AppMotion.slow,
      themeAnimationCurve: Curves.easeInOut,
      home: AnimatedSwitcher(
        duration: AppMotion.slow,
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: home,
      ),
    );
  }
}
