import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Map<String, dynamic>? _scoutData;

  @override
  void initState() {
    super.initState();
    _loadScout();
  }

  Future<void> _loadScout() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    final data = await Supabase.instance.client.from('scouts').select().eq('id', uid).maybeSingle();
    if (data == null) {
      // First time - go to register
      if (mounted) context.go('/register');
      return;
    }
    if (mounted) setState(() => _scoutData = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaivahikam'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () async {
            await Supabase.instance.client.auth.signOut();
            if (mounted) context.go('/login');
          }),
        ],
      ),
      body: _scoutData == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadScout,
              child: ListView(padding: const EdgeInsets.all(16), children: [
                // Welcome
                Text('Welcome, ${_scoutData!['name'] ?? 'Scout'}!', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                // Stats row
                Row(children: [
                  _StatCard(label: 'Credits', value: '${_scoutData!['wallet_balance'] ?? 0}', icon: Icons.monetization_on, color: Colors.amber),
                  const SizedBox(width: 12),
                  _StatCard(label: 'Uploads', value: '${_scoutData!['total_uploads'] ?? 0}', icon: Icons.upload, color: Colors.green),
                  const SizedBox(width: 12),
                  _StatCard(label: 'Trust', value: '${_scoutData!['trust_score'] ?? 100}', icon: Icons.verified, color: Colors.blue),
                ]),
                const SizedBox(height: 24),
                // Quick Actions
                Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _ActionTile(icon: Icons.search, label: 'Find Best Match', subtitle: 'Smart AI-powered matching', color: Theme.of(context).colorScheme.primary, onTap: () => context.push('/search')),
                _ActionTile(icon: Icons.person_add, label: 'Upload Profile', subtitle: 'Earn 3 credits per upload', color: Colors.green, onTap: () => context.push('/upload')),
                _ActionTile(icon: Icons.folder_shared, label: 'My Shortlists', subtitle: 'Organize matches by client', color: Colors.purple, onTap: () => context.push('/shortlists')),
                _ActionTile(icon: Icons.account_balance_wallet, label: 'Wallet & Credits', subtitle: 'Buy credits, view history', color: Colors.orange, onTap: () => context.push('/wallet')),
              ]),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      Icon(icon, color: color, size: 28),
      const SizedBox(height: 8),
      Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
    ]))));
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withAlpha(30), child: Icon(icon, color: color)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
