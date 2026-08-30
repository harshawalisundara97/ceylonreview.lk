import 'package:flutter/material.dart';

import '../../../core/l10n_ext.dart';

/// Placeholder for the "Saved" tab — collections of saved places.
/// Built out in a later branch (see docs/design_handoff_ceylonreview_mobile).
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSaved)),
      body: Center(
        child: Text(l10n.comingSoon,
            style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
