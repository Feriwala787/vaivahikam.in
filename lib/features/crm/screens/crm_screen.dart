import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CrmScreen extends ConsumerStatefulWidget {
  const CrmScreen({super.key});

  @override
  ConsumerState<CrmScreen> createState() => _CrmScreenState();
}

class _CrmScreenState extends ConsumerState<CrmScreen> {
  List<Map<String, dynamic>> _folders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    final data = await Supabase.instance.client
        .from('shortlist_folders')
        .select('*, shortlist_items(count)')
        .eq('scout_id', uid)
        .order('created_at', ascending: false);
    if (mounted) setState(() { _folders = List<Map<String, dynamic>>.from(data); _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Shortlists')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _folders.isEmpty
              ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No shortlists yet'),
                  Text('Create folders to organize matches for clients', style: TextStyle(color: Colors.grey)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _folders.length,
                  itemBuilder: (_, i) {
                    final folder = _folders[i];
                    final count = folder['shortlist_items']?[0]?['count'] ?? 0;
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.folder)),
                        title: Text(folder['name']),
                        subtitle: Text('$count profiles'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteFolder(folder['id']),
                        ),
                        onTap: () {}, // TODO: Open folder detail
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createFolder,
        icon: const Icon(Icons.create_new_folder),
        label: const Text('New Folder'),
      ),
    );
  }

  Future<void> _createFolder() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(context: context, builder: (_) => AlertDialog(
      title: const Text('New Shortlist Folder'),
      content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'e.g. Matches for Sharma Ji')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Create')),
      ],
    ));
    if (name != null && name.isNotEmpty) {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      await Supabase.instance.client.from('shortlist_folders').insert({'scout_id': uid, 'name': name});
      _loadFolders();
    }
  }

  Future<void> _deleteFolder(String id) async {
    await Supabase.instance.client.from('shortlist_folders').delete().eq('id', id);
    _loadFolders();
  }
}
