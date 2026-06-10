import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/places_provider.dart';
import '../../../application/reviews_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/models/place.dart';
import '../../widgets/star_picker.dart';

/// Write Review: pick a place (preselected when opened from a place),
/// tap a star rating, write the text, post.
class WriteReviewScreen extends ConsumerStatefulWidget {
  const WriteReviewScreen({super.key, this.initialPlaceId});

  final String? initialPlaceId;

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  String? _placeId;
  int _rating = 0;
  final _text = TextEditingController();
  bool _posting = false;

  @override
  void initState() {
    super.initState();
    _placeId = widget.initialPlaceId;
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final messenger = ScaffoldMessenger.of(context);
    if (_placeId == null) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Choose a place to review.')));
      return;
    }
    if (_rating == 0) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Tap the stars to rate your visit.')));
      return;
    }
    if (_text.text.trim().length < 10) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Tell us a little more — at least 10 characters.')));
      return;
    }

    setState(() => _posting = true);
    try {
      await ref.read(reviewSubmitterProvider).submit(
            placeId: _placeId!,
            rating: _rating,
            text: _text.text.trim(),
          );
      if (!mounted) return;
      messenger.showSnackBar(
          const SnackBar(content: Text('Review posted. Thank you!')));
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          _rating = 0;
          _text.clear();
          if (widget.initialPlaceId == null) _placeId = null;
        });
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placesAsync = ref.watch(allPlacesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Write a Review')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          children: [
            Text('Place', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            placesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Could not load places.'),
              data: (places) => DropdownButtonFormField<String>(
                value: _placeId,
                isExpanded: true,
                hint: const Text('Choose a place'),
                items: [
                  for (final Place p in places)
                    DropdownMenuItem(
                      value: p.id,
                      child: Text(p.name, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: widget.initialPlaceId != null
                    ? null
                    : (v) => setState(() => _placeId = v),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Your rating', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            StarPicker(
              value: _rating,
              onChanged: (v) => setState(() => _rating = v),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Your review', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _text,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText:
                    'Share what you loved — the food, the views, the welcome…',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _posting ? null : _post,
              child: _posting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Post Review'),
            ),
          ],
        ),
      ),
    );
  }
}
