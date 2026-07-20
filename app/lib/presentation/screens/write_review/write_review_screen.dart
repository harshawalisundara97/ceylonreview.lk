import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../application/places_provider.dart';
import '../../../application/reviews_provider.dart';
import '../../../core/l10n_ext.dart';
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
  final List<Uint8List> _photoBytes = [];

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

  Future<void> _pickPhoto(ImageSource source) async {
    if (_photoBytes.length >= 3) return;
    final picked = await ImagePicker()
        .pickImage(source: source, maxWidth: 1600, imageQuality: 80);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _photoBytes.add(bytes));
  }

  void _removePhoto(int index) => setState(() => _photoBytes.removeAt(index));

  Future<void> _post() async {
    final messenger = ScaffoldMessenger.of(context);
    if (_placeId == null) {
      messenger.showSnackBar(
          SnackBar(content: Text(context.l10n.chooseAPlaceToReview)));
      return;
    }
    if (_rating == 0) {
      messenger.showSnackBar(
          SnackBar(content: Text(context.l10n.tapStarsToRate)));
      return;
    }
    if (_text.text.trim().length < 10) {
      messenger.showSnackBar(SnackBar(
          content: Text(context.l10n.tellUsMore)));
      return;
    }

    setState(() => _posting = true);
    try {
      await ref.read(reviewSubmitterProvider).submit(
            placeId: _placeId!,
            rating: _rating,
            text: _text.text.trim(),
            photoBytes: _photoBytes,
          );
      if (!mounted) return;
      messenger.showSnackBar(
          SnackBar(content: Text(context.l10n.reviewPostedThankYou)));
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          _rating = 0;
          _text.clear();
          _photoBytes.clear();
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
      appBar: AppBar(title: Text(context.l10n.writeAReview)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          children: [
            Text(context.l10n.place, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            placesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => Text(context.l10n.couldNotLoadPlaces),
              data: (places) => DropdownButtonFormField<String>(
                value: _placeId,
                isExpanded: true,
                hint: Text(context.l10n.chooseAPlace),
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
            Text(context.l10n.yourRating, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            StarPicker(
              value: _rating,
              onChanged: (v) => setState(() => _rating = v),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(context.l10n.addPhotosOptional,
                style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_camera_rounded),
                    label: Text(context.l10n.camera),
                    onPressed: _photoBytes.length >= 3
                        ? null
                        : () => _pickPhoto(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library_rounded),
                    label: Text(context.l10n.gallery),
                    onPressed: _photoBytes.length >= 3
                        ? null
                        : () => _pickPhoto(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            if (_photoBytes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photoBytes.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (_, i) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(_photoBytes[i],
                            width: 72, height: 72, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => _removePhoto(i),
                          child: const CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close_rounded,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Text(context.l10n.yourReview, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _text,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: context.l10n.shareWhatYouLoved,
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
                  : Text(context.l10n.postReview),
            ),
          ],
        ),
      ),
    );
  }
}
