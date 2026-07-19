import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/locale_provider.dart';
import '../../core/l10n_ext.dart';

/// Modal sheet listing System default / English / සිංහල / தமிழ், with the
/// active choice checked. Selecting persists via [localeProvider].
Future<void> showLanguagePicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => Consumer(
      builder: (context, ref, _) {
        final current = ref.watch(localeProvider);
        void select(Locale? locale) {
          ref.read(localeProvider.notifier).setLocale(locale);
          Navigator.of(sheetContext).pop();
        }

        Widget option(String label, Locale? locale) => ListTile(
              title: Text(label),
              trailing:
                  current == locale ? const Icon(Icons.check_rounded) : null,
              onTap: () => select(locale),
            );

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  context.l10n.language,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              option(context.l10n.systemDefault, null),
              option('English', const Locale('en')),
              option('සිංහල', const Locale('si')),
              option('தமிழ்', const Locale('ta')),
            ],
          ),
        );
      },
    ),
  );
}
