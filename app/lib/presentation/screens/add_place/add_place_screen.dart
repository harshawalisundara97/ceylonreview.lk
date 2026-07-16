import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../../application/add_place_controller.dart';
import '../../../application/location_provider.dart';
import '../../../application/repository_providers.dart';
import '../../../core/sri_lanka_districts.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/models/category.dart';
import '../../widgets/filters_bottom_sheet.dart' show categoryHasPricing;
import '../place_detail/place_detail_screen.dart';

/// Form for adding a community place: details, optional photo
/// (camera/gallery), and a map-pinned location.
class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key, this.initialName});

  /// Prefill for the name field (from the search empty state).
  final String? initialName;

  @override
  ConsumerState<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  static const _islandCenter = LatLng(7.5, 80.7);

  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.initialName);
  String? _district;
  final _descriptionController = TextEditingController();

  PlaceCategory? _category;
  int? _priceLevel;
  TimeOfDay? _opensAt;
  TimeOfDay? _closesAt;
  XFile? _photo;
  LatLng? _pin;
  bool _submitting = false;
  final _mapController = MapController();
  final _searchController = TextEditingController();
  bool _searching = false;
  String? _searchError;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String? _hhmm(TimeOfDay? t) => t == null
      ? null
      : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await ImagePicker()
        .pickImage(source: source, maxWidth: 1600, imageQuality: 80);
    if (picked != null) setState(() => _photo = picked);
  }

  Future<void> _useCurrentLocation() async {
    await ref.read(locationProvider.notifier).refresh();
    final position = ref.read(locationProvider).valueOrNull;
    if (position == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Enable location to use your position.')));
      }
      return;
    }
    setState(() => _pin = LatLng(position.latitude, position.longitude));
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _searching = true;
      _searchError = null;
    });
    try {
      final result =
          await ref.read(geocodingRepositoryProvider).search(query);
      if (result == null) {
        setState(() => _searchError = 'No results found for "$query".');
        return;
      }
      setState(() => _pin = result);
      _mapController.move(result, 13);
    } catch (_) {
      setState(() => _searchError = 'Search failed — check your connection.');
    } finally {
      setState(() => _searching = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null || _pin == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_category == null
              ? 'Pick a category.'
              : 'Drop a pin for the location.')));
      return;
    }
    setState(() => _submitting = true);
    try {
      final place = await ref.read(addPlaceControllerProvider.notifier).submit(
            name: _nameController.text.trim(),
            category: _category!,
            district: _district!,
            description: _descriptionController.text.trim(),
            latitude: _pin!.latitude,
            longitude: _pin!.longitude,
            priceLevel: categoryHasPricing(_category!) ? _priceLevel : null,
            opensAt: _hhmm(_opensAt),
            closesAt: _hhmm(_closesAt),
            photoBytes: _photo == null ? null : await _photo!.readAsBytes(),
          );
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => PlaceDetailScreen(placeId: place.id)));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Could not add the place. Please try again.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Add a Place')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Category', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final c in PlaceCategory.selectable)
                  ChoiceChip(
                    label: Text(c.label),
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<String>(
              value: _district,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'District'),
              hint: const Text('Choose a district'),
              items: [
                for (final d in sriLankaDistricts)
                  DropdownMenuItem(value: d, child: Text(d)),
              ],
              onChanged: (v) => setState(() => _district = v),
              validator: (v) =>
                  v == null ? 'District is required' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _descriptionController,
              decoration:
                  const InputDecoration(labelText: 'Description (optional)'),
              maxLines: 3,
            ),
            if (_category != null && categoryHasPricing(_category!)) ...[
              const SizedBox(height: AppSpacing.lg),
              Text('Price level', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (var level = 1; level <= 3; level++)
                    ChoiceChip(
                      label: Text('₨' * level),
                      selected: _priceLevel == level,
                      onSelected: (_) => setState(() =>
                          _priceLevel = _priceLevel == level ? null : level),
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text('Opening hours (optional)', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final t = await showTimePicker(
                          context: context,
                          initialTime:
                              _opensAt ?? const TimeOfDay(hour: 9, minute: 0));
                      if (t != null) setState(() => _opensAt = t);
                    },
                    child: Text(_opensAt == null
                        ? 'Opens at'
                        : 'Opens ${_hhmm(_opensAt)}'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final t = await showTimePicker(
                          context: context,
                          initialTime: _closesAt ??
                              const TimeOfDay(hour: 18, minute: 0));
                      if (t != null) setState(() => _closesAt = t);
                    },
                    child: Text(_closesAt == null
                        ? 'Closes at'
                        : 'Closes ${_hhmm(_closesAt)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Photo (optional)', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_camera_rounded),
                    label: const Text('Camera'),
                    onPressed: () => _pickPhoto(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('Gallery'),
                    onPressed: () => _pickPhoto(ImageSource.gallery),
                  ),
                ),
                if (_photo != null) ...[
                  const SizedBox(width: AppSpacing.md),
                  const Icon(Icons.check_circle_rounded, color: Colors.green),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Location — tap the map or use your position',
                style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('locationSearchField'),
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search a town or landmark',
                      hintText: 'e.g. Ella, Galle Fort',
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _searchLocation(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  key: const Key('locationSearchButton'),
                  icon: _searching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.search_rounded),
                  onPressed: _searching ? null : _searchLocation,
                ),
              ],
            ),
            if (_searchError != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(_searchError!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.error)),
              ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 240,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _pin ?? _islandCenter,
                    initialZoom: _pin == null ? 7.3 : 13,
                    onTap: (_, point) => setState(() => _pin = point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.ceylonreview.ceylon_review',
                    ),
                    if (_pin != null)
                      MarkerLayer(markers: [
                        Marker(
                          point: _pin!,
                          width: 44,
                          height: 44,
                          child: Icon(Icons.location_pin,
                              size: 40, color: theme.colorScheme.primary),
                        ),
                      ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              icon: const Icon(Icons.my_location_rounded),
              label: const Text('Use my current location'),
              onPressed: _useCurrentLocation,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Add Place'),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
