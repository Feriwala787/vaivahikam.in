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
      appBar: AppBar(title: Text(_unlocked ? p.name : 'Profile Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: p.photosUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(p.photosUrl.first, fit: BoxFit.cover))
                  : const Center(child: Icon(Icons.person, size: 80)),
            ),
            const SizedBox(height: 16),
            if (!_unlocked) ...[
              Card(
                color: Colors.amber[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.lock, size: 32, color: Colors.orange),
                      const SizedBox(height: 8),
                      const Text('Spend 1 Credit to unlock full profile', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _unlockProfile, child: const Text('Unlock (1 Credit)')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Visible stats (always shown)
            _SectionCard(title: 'Basic Info', children: [
              _InfoRow('Age', '${p.age} years'),
              _InfoRow('Height', '${p.height} cm'),
              _InfoRow('Marital Status', p.maritalStatus),
            ]),
            _SectionCard(title: 'Cultural', children: [
              _InfoRow('Religion', p.religion),
              _InfoRow('Caste', p.caste),
              if (p.subCaste != null) _InfoRow('Sub-Caste', p.subCaste!),
              _InfoRow('Manglik', p.manglik),
            ]),
            _SectionCard(title: 'Professional', children: [
              _InfoRow('Education', p.education),
              _InfoRow('Profession', p.profession),
              _InfoRow('Income', p.income),
            ]),
            _SectionCard(title: 'Lifestyle', children: [
              _InfoRow('Diet', p.diet),
              _InfoRow('Family Type', p.familyType),
              _InfoRow('City', p.city),
              _InfoRow('State', p.state),
            ]),
            if (_unlocked && p.bio != null) ...[
              const SizedBox(height: 8),
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(p.bio!))),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _unlockProfile() async {
    // TODO: Integrate with backend credit deduction
    setState(() => _unlocked = true);
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
