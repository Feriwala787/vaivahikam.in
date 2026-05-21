import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/app_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _territoryController = TextEditingController();
  bool _loading = false;

  Future<void> _register() async {
    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) return;
    setState(() => _loading = true);

    try {
      final backend = ref.read(backendServiceProvider);
      final result = await backend.registerScout(
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _territoryController.text.trim().isEmpty ? null : _territoryController.text.trim(),
      );

      if (result['error'] != null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['error'])));
      } else {
        if (mounted) context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Registration')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Welcome, Scout!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Complete your profile to start uploading and searching matches.'),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number', prefixText: '+91 '),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _territoryController,
              decoration: const InputDecoration(labelText: 'Territory / City (optional)'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loading ? null : _register,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: _loading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Text('Register & Start', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
