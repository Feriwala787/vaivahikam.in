import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/app_providers.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/profile_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(matchFilterProvider);
    final resultsAsync = ref.watch(searchResultsProvider(_currentPage));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Match'),
        actions: [
          if (filter.hasActiveFilters)
            TextButton.icon(
              onPressed: () => ref.read(matchFilterProvider.notifier).clearFilters(),
              icon: const Icon(Icons.clear, color: Colors.white, size: 18),
              label: const Text('Clear', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Quick filter chips
          _QuickFilterBar(ref: ref, filter: filter),
          // Results
          Expanded(
            child: resultsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (profiles) {
                if (profiles.isEmpty) {
                  return const Center(child: Text('No profiles found.\nTry adjusting your filters.'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: profiles.length,
                  itemBuilder: (_, i) => ProfileCard(
                    profile: profiles[i],
                    onTap: () => context.push('/profile/${profiles[i].id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAdvancedFilters(context),
        icon: const Icon(Icons.tune),
        label: Text(filter.hasActiveFilters ? 'Filters Active' : 'Filters'),
      ),
    );
  }

  void _showAdvancedFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const FilterSheet(),
    );
  }
}

class _QuickFilterBar extends StatelessWidget {
  final WidgetRef ref;
  final dynamic filter;

  const _QuickFilterBar({required this.ref, required this.filter});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _QuickChip(
              label: filter.gender ?? 'Gender',
              active: filter.gender != null,
              onTap: () => _showGenderPicker(context),
            ),
            _QuickChip(
              label: filter.religion ?? 'Religion',
              active: filter.religion != null,
              onTap: () => _showReligionPicker(context),
            ),
            _QuickChip(
              label: filter.caste ?? 'Caste',
              active: filter.caste != null,
              onTap: () => _showCastePicker(context),
            ),
            _QuickChip(
              label: filter.city ?? 'City',
              active: filter.city != null,
              onTap: () => _showCityInput(context),
            ),
            _QuickChip(
              label: filter.ageMin != null ? '${filter.ageMin}-${filter.ageMax ?? 60}' : 'Age',
              active: filter.ageMin != null,
              onTap: () => _showAgePicker(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showGenderPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Select Gender'),
        children: ['Male', 'Female'].map((g) => SimpleDialogOption(
          onPressed: () {
            ref.read(matchFilterProvider.notifier).setGender(g);
            Navigator.pop(context);
          },
          child: Text(g),
        )).toList(),
      ),
    );
  }

  void _showReligionPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Select Religion'),
        children: ['Hindu', 'Muslim', 'Sikh', 'Christian', 'Jain'].map((r) => SimpleDialogOption(
          onPressed: () {
            ref.read(matchFilterProvider.notifier).setReligion(r);
            Navigator.pop(context);
          },
          child: Text(r),
        )).toList(),
      ),
    );
  }

  void _showCastePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Select Caste'),
        children: ['Brahmin', 'Rajput', 'Baniya', 'Jat', 'Agarwal', 'Khatri', 'Patel', 'Other']
            .map((c) => SimpleDialogOption(
          onPressed: () {
            ref.read(matchFilterProvider.notifier).setCaste(c);
            Navigator.pop(context);
          },
          child: Text(c),
        )).toList(),
      ),
    );
  }

  void _showCityInput(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enter City'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'City name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(matchFilterProvider.notifier).setCity(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showAgePicker(BuildContext context) {
    RangeValues range = const RangeValues(18, 40);
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Age Range'),
          content: RangeSlider(
            values: range,
            min: 18,
            max: 60,
            divisions: 42,
            labels: RangeLabels('${range.start.round()}', '${range.end.round()}'),
            onChanged: (v) => setDialogState(() => range = v),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                ref.read(matchFilterProvider.notifier).setAgeRange(range.start.round(), range.end.round());
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _QuickChip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => onTap(),
        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      ),
    );
  }
}
