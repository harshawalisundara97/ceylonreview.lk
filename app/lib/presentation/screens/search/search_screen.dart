import 'package:flutter/material.dart';

import '../../../core/l10n_ext.dart';

/// Placeholder for the dedicated Search & Filters screen, reached by
/// tapping the search bar on Home. Built out in a later branch (see
/// docs/design_handoff_ceylonreview_mobile).
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.search)),
      body: Center(
        child: Text(l10n.comingSoon,
            style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
