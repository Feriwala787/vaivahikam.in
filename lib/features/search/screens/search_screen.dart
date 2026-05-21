import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/profile.dart';
import '../../../providers/app_providers.dart';
import '../../../services/match_engine.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/profile_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _matchEngine = MatchEngine();
  Profile? _seekerProfile; // The profile we're finding matches FOR
  bool _useSmartRanking = true;

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(matchFilterProvider);
    final resultsAsync = ref.watch(searchResultsProvider(0));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Match'),
        actions: [
          // Smart ranking toggle
          IconButton(
            icon: Icon(_useSmartRanking ? Icons.auto_awesome : Icons.sort, color: Colors.white),
            tooltip: _useSmartRanking ? 'Smart Ranking ON' : 'Smart Ranking OFF',
            onPressed: () => setState(() => _useSmartRanking = !_useSmartRanking),
          ),
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
          // Seeker selector
          if (_seekerProfile != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.green.shade50,
              child: Row(children: [
                const Icon(Icons.person_search, size: 18, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text('Finding matches for: ${_seekerProfile!.name}', style: const TextStyle(fontSize: 13))),
                IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => setState(() => _seekerProfile = null)),
              ]),
            ),
          // Results
          Expanded(
            child: resultsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (profiles) {
                if (profiles.isEmpty) {
                  return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No profiles found', style: TextStyle(fontSize: 18)),
                    Text('Try adjusting your filters', style: TextStyle(color: Colors.grey)),
                  ]));
                }

                // Apply smart ranking if seeker is set
                if (_useSmartRanking && _seekerProfile != null) {
                  final ranked = _matchEngine.rankMatches(_seekerProfile!, profiles);
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: ranked.length,
                    itemBuilder: (_, i) => _ScoredProfileCard(
                      profile: ranked[i].key,
                      score: ranked[i].value,
                      onTap: () => context.push('/profile/${ranked[i].key.id}'),
                    ),
                  );
                }

                // Regular grid
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 10, mainAxisSpacing: 10,
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'seeker',
            onPressed: () => _selectSeeker(context),
            child: const Icon(Icons.person_search),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'filter',
            onPressed: () => _showAdvancedFilters(context),
            icon: const Icon(Icons.tune),
            label: Text(filter.hasActiveFilters ? 'Filters Active' : 'Filters'),
          ),
        ],
      ),
    );
  }

  void _showAdvancedFilters(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const FilterSheet(),
    );
  }

  void _selectSeeker(BuildContext context) {
    // Let scout pick which profile they're finding matches for
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Client Profile'),
        content: const Text('Choose the profile you want to find matches for. Results will be ranked by compatibility.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // For now use first result as demo seeker
              final results = ref.read(searchResultsProvider(0));
              results.whenData((profiles) {
                if (profiles.isNotEmpty) setState(() => _seekerProfile = profiles.first);
              });
            },
            child: const Text('Use First Profile (Demo)'),
          ),
        ],
      ),
    );
  }
}

// Scored profile card with compatibility breakdown
class _ScoredProfileCard extends StatelessWidget {
  final Profile profile;
  final MatchScore score;
  final VoidCallback onTap;

  const _ScoredProfileCard({required this.profile, required this.score, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Photo
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[200]),
                child: profile.photosUrl.isNotEmpty
                    ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(profile.photosUrl.first, fit: BoxFit.cover))
                    : const Icon(Icons.person, size: 32),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${profile.age} yrs, ${profile.height} cm • ${profile.caste}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('${profile.profession} • ${profile.city}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  // Score breakdown chips
                  Wrap(spacing: 4, runSpacing: 4, children: [
                    ...score.breakdown.entries.take(3).map((e) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: e.value.startsWith('✓') ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('${e.key}: ${e.value}', style: TextStyle(fontSize: 10,
                        color: e.value.startsWith('✓') ? Colors.green.shade700 : Colors.red.shade700)),
                    )),
                  ]),
                ]),
              ),
              // Score badge
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _scoreColor(score.total),
                ),
                child: Center(child: Text('${score.total.round()}%',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _scoreColor(double s) {
    if (s >= 80) return Colors.green;
    if (s >= 60) return Colors.orange;
    if (s >= 40) return Colors.deepOrange;
    return Colors.red;
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
        child: Row(children: [
          _chip(filter.gender ?? 'Gender', filter.gender != null, () => _pickGender(context)),
          _chip(filter.religion ?? 'Religion', filter.religion != null, () => _pickReligion(context)),
          _chip(filter.caste ?? 'Caste', filter.caste != null, () => _pickCaste(context)),
          _chip(filter.city ?? 'City', filter.city != null, () => _pickCity(context)),
          _chip(filter.ageMin != null ? '${filter.ageMin}-${filter.ageMax ?? 60}' : 'Age', filter.ageMin != null, () => _pickAge(context)),
        ]),
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(label: Text(label), selected: active, onSelected: (_) => onTap()));
  }

  void _pickGender(BuildContext ctx) => _showPicker(ctx, 'Gender', ['Male', 'Female'], (v) => ref.read(matchFilterProvider.notifier).setGender(v));
  void _pickReligion(BuildContext ctx) => _showPicker(ctx, 'Religion', ['Hindu', 'Muslim', 'Sikh', 'Christian', 'Jain'], (v) => ref.read(matchFilterProvider.notifier).setReligion(v));
  void _pickCaste(BuildContext ctx) => _showPicker(ctx, 'Caste', ['Brahmin', 'Rajput', 'Baniya', 'Jat', 'Agarwal', 'Khatri', 'Patel', 'Other'], (v) => ref.read(matchFilterProvider.notifier).setCaste(v));

  void _pickCity(BuildContext ctx) {
    final c = TextEditingController();
    showDialog(context: ctx, builder: (_) => AlertDialog(
      title: const Text('City'), content: TextField(controller: c, decoration: const InputDecoration(hintText: 'Enter city')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(onPressed: () { ref.read(matchFilterProvider.notifier).setCity(c.text.trim()); Navigator.pop(ctx); }, child: const Text('Apply'))],
    ));
  }

  void _pickAge(BuildContext ctx) {
    RangeValues r = const RangeValues(18, 40);
    showDialog(context: ctx, builder: (_) => StatefulBuilder(builder: (c, set) => AlertDialog(
      title: const Text('Age Range'),
      content: RangeSlider(values: r, min: 18, max: 60, divisions: 42, labels: RangeLabels('${r.start.round()}', '${r.end.round()}'), onChanged: (v) => set(() => r = v)),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(onPressed: () { ref.read(matchFilterProvider.notifier).setAgeRange(r.start.round(), r.end.round()); Navigator.pop(ctx); }, child: const Text('Apply'))],
    )));
  }

  void _showPicker(BuildContext ctx, String title, List<String> opts, ValueChanged<String> onPick) {
    showDialog(context: ctx, builder: (_) => SimpleDialog(title: Text(title),
      children: opts.map((o) => SimpleDialogOption(onPressed: () { onPick(o); Navigator.pop(ctx); }, child: Text(o))).toList()));
  }
}
