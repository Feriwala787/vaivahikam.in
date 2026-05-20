import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/profile.dart';
import '../../../providers/app_providers.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  int _age = 25;
  int _height = 165;
  String _gender = 'Male';
  String _religion = 'Hindu';
  String _caste = 'Brahmin';
  String _manglik = 'No';
  String _education = 'Graduate';
  String _profession = 'Private Job';
  String _income = '5-10 Lakh';
  String _diet = 'Vegetarian';
  String _maritalStatus = 'Never Married';
  String _familyType = 'Nuclear';
  String _state = 'Delhi';
  bool _loading = false;
  final List<XFile> _photos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo upload
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: _photos.isEmpty
                      ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.add_a_photo, size: 32, color: Colors.grey),
                          Text('Add Photos', style: TextStyle(color: Colors.grey)),
                        ])
                      : Text('${_photos.length} photo(s) selected'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            // Gender
            _dropdown('Gender', _gender, ['Male', 'Female'], (v) => setState(() => _gender = v!)),
            // Age slider
            _sliderField('Age', _age, 18, 60, (v) => setState(() => _age = v.round())),
            // Height slider
            _sliderField('Height (cm)', _height, 140, 200, (v) => setState(() => _height = v.round())),
            // Religion
            _dropdown('Religion', _religion, AppConstants.religions, (v) => setState(() => _religion = v!)),
            // Caste
            _dropdown('Caste', _caste, AppConstants.hinduCastes, (v) => setState(() => _caste = v!)),
            // Manglik
            _dropdown('Manglik', _manglik, AppConstants.manglikOptions, (v) => setState(() => _manglik = v!)),
            // Education
            _dropdown('Education', _education, AppConstants.educationLevels, (v) => setState(() => _education = v!)),
            // Profession
            _dropdown('Profession', _profession, AppConstants.professions, (v) => setState(() => _profession = v!)),
            // Income
            _dropdown('Income', _income, AppConstants.incomeRanges, (v) => setState(() => _income = v!)),
            // Diet
            _dropdown('Diet', _diet, AppConstants.dietOptions, (v) => setState(() => _diet = v!)),
            // Marital Status
            _dropdown('Marital Status', _maritalStatus, AppConstants.maritalStatuses, (v) => setState(() => _maritalStatus = v!)),
            // Family Type
            _dropdown('Family Type', _familyType, AppConstants.familyTypes, (v) => setState(() => _familyType = v!)),
            // State
            _dropdown('State', _state, AppConstants.states, (v) => setState(() => _state = v!)),
            // City
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'City'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: _loading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Text('Upload Profile (+3 Credits)', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _sliderField(String label, int value, double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: $value'),
          Slider(value: value.toDouble(), min: min, max: max, divisions: (max - min).round(), onChanged: onChanged),
        ],
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) setState(() => _photos.addAll(images));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final scout = ref.read(currentScoutProvider);
      final service = ref.read(supabaseServiceProvider);

      // TODO: Upload photos with compression, get URLs
      final profile = Profile(
        id: '',
        scoutId: scout?.id ?? '',
        name: _nameController.text.trim(),
        gender: _gender,
        age: _age,
        height: _height,
        religion: _religion,
        caste: _caste,
        manglik: _manglik,
        education: _education,
        profession: _profession,
        income: _income,
        diet: _diet,
        maritalStatus: _maritalStatus,
        familyType: _familyType,
        city: _cityController.text.trim(),
        state: _state,
        photosUrl: [],
        createdAt: DateTime.now(),
      );

      await service.uploadProfile(profile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile uploaded! +3 Credits')));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => _loading = false);
  }
}
