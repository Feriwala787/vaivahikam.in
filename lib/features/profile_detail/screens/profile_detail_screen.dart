import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/profile.dart';
import '../../../providers/app_providers.dart';

class ProfileDetailScreen extends ConsumerStatefulWidget {
  final String profileId;
  const ProfileDetailScreen({super.key, required this.profileId});

  @override
  ConsumerState<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends ConsumerState<ProfileDetailScreen> {
  Profile? _profile;
  bool _unlocked = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final service = ref.read(supabaseServiceProvider);
    final scout = ref.read(currentScoutProvider);
    final profile = await service.getProfile(widget.profileId);
    final unlocked = scout != null ? await service.hasUnlocked(scout.id, widget.profileId) : false;
    if (mounted) setState(() { _profile = profile; _unlocked = unlocked; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_profile == null) return const Scaffold(body: Center(child: Text('Profile not found')));

    final p = _profile!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_unlocked ? p.name : 'Profile Details'),
        actions: [
          if (_unlocked) IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(icon: const Icon(Icons.report), onPressed: () => _reportProfile(p.id)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Photo
          Container(
            height: 220,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[200]),
            child: p.photosUrl.isNotEmpty
                ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(p.photosUrl.first, fit: BoxFit.cover))
                : const Center(child: Icon(Icons.person, size: 80)),
          ),
          const SizedBox(height: 16),

          // Unlock card
          if (!_unlocked) ...[
            Card(color: Colors.amber[50], child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
              const Icon(Icons.lock, size: 32, color: Colors.orange),
              const SizedBox(height: 8),
              const Text('Spend 1 Credit to unlock full profile & contact', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _unlockProfile, child: const Text('Unlock (1 Credit)')),
            ]))),
            const SizedBox(height: 16),
          ],

          // Basic Info
          _section('Basic Info', [
            _row('Age', '${p.age} years'),
            _row('Height', '${p.height} cm'),
            _row('Marital Status', p.maritalStatus),
            if (p.complexion != null) _row('Complexion', p.complexion!),
            if (p.bodyType != null) _row('Body Type', p.bodyType!),
          ]),

          // Cultural
          _section('Cultural', [
            _row('Religion', p.religion),
            _row('Caste', p.caste),
            if (p.subCaste != null) _row('Sub-Caste', p.subCaste!),
            if (p.gotra != null) _row('Gotra', p.gotra!),
            _row('Manglik', p.manglik),
          ]),

          // Professional
          _section('Professional & Economic', [
            _row('Education', p.education),
            _row('Profession', p.profession),
            _row('Income', p.income),
            if (p.familyWealth != null) _row('Family Wealth', p.familyWealth!),
            if (p.familyIncome != null) _row('Family Income', p.familyIncome!),
            if (p.propertyOwned != null) _row('Property', p.propertyOwned!),
          ]),

          // Social
          _section('Social & Family', [
            _row('Family Type', p.familyType),
            _row('City', p.city),
            _row('State', p.state),
            if (p.fatherOccupation != null) _row("Father's Occupation", p.fatherOccupation!),
            if (p.socialStatus != null) _row('Social Status', p.socialStatus!),
            if (p.familyValues != null) _row('Family Values', p.familyValues!),
            if (p.livingPreference != null) _row('Living Preference', p.livingPreference!),
            if (p.socialCircle != null) _row('Social Circle', p.socialCircle!),
          ]),

          // Psychological
          if (p.personality != null || p.temperament != null || p.lifeGoals != null)
            _section('Personality & Mindset', [
              if (p.personality != null) _row('Personality', p.personality!),
              if (p.temperament != null) _row('Temperament', p.temperament!),
              if (p.lifeGoals != null) _row('Life Goals', p.lifeGoals!),
              if (p.communicationStyle != null) _row('Communication', p.communicationStyle!),
              if (p.politicalView != null) _row('Political View', p.politicalView!),
              if (p.religiousLevel != null) _row('Religious Level', p.religiousLevel!),
            ]),

          // Lifestyle
          _section('Lifestyle', [
            _row('Diet', p.diet),
            if (p.exerciseHabit != null) _row('Exercise', p.exerciseHabit!),
            if (p.smokingHabit != null) _row('Smoking', p.smokingHabit!),
            if (p.drinkingHabit != null) _row('Drinking', p.drinkingHabit!),
          ]),

          // Partner Preferences
          if (p.prefAgeMin != null || p.prefReligion != null)
            _section('Looking For', [
              if (p.prefAgeMin != null) _row('Age', '${p.prefAgeMin} - ${p.prefAgeMax}'),
              if (p.prefHeightMin != null) _row('Height', '${p.prefHeightMin} - ${p.prefHeightMax} cm'),
              if (p.prefReligion != null) _row('Religion', p.prefReligion!),
              if (p.prefCaste != null) _row('Caste', p.prefCaste!),
              if (p.prefIncome != null) _row('Income', p.prefIncome!),
              if (p.prefDiet != null) _row('Diet', p.prefDiet!),
              if (p.prefManglik != null) _row('Manglik', p.prefManglik!),
            ]),

          if (p.bio != null) ...[
            const SizedBox(height: 8),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(p.bio!))),
          ],
        ]),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const Divider(), ...children,
      ],
    )));
  }

  Widget _row(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: TextStyle(color: Colors.grey[600])), Text(value, style: const TextStyle(fontWeight: FontWeight.w500))],
    ));
  }

  Future<void> _unlockProfile() async {
    setState(() => _loading = true);
    try {
      final backend = ref.read(backendServiceProvider);
      final result = await backend.unlockProfile(widget.profileId);
      if (result['error'] != null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['error'])));
      } else {
        setState(() => _unlocked = true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => _loading = false);
  }

  Future<void> _reportProfile(String id) async {
    final confirm = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('Report Fake Profile?'),
      content: const Text('If confirmed fake, you get 1 credit refund and uploader loses 5 credits.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Report', style: TextStyle(color: Colors.red))),
      ],
    ));
    if (confirm == true) {
      final backend = ref.read(backendServiceProvider);
      final result = await backend.reportProfile(id);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? result['error'] ?? 'Done')));
    }
  }
}
