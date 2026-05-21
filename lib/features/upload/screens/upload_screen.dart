import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/profile.dart';
import '../../../providers/app_providers.dart';
import '../../../services/image_service.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;
  bool _loading = false;
  final List<XFile> _photos = [];

  // Basic
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  int _age = 25, _height = 165;
  String _gender = 'Male';

  // Cultural
  String _religion = 'Hindu', _caste = 'Brahmin', _manglik = 'No';
  String _maritalStatus = 'Never Married';
  final _gotraController = TextEditingController();
  final _subCasteController = TextEditingController();

  // Professional/Economic
  String _education = 'Graduate', _profession = 'Private Job', _income = '5-10 Lakh';
  String? _familyWealth, _propertyOwned, _familyIncome;

  // Social
  String _familyType = 'Nuclear', _state = 'Delhi';
  String? _socialStatus, _familyValues, _livingPreference, _socialCircle;
  final _fatherOccController = TextEditingController();

  // Psychological
  String? _personality, _temperament, _lifeGoals, _communicationStyle;

  // Political/Ideological
  String? _politicalView, _religiousLevel;

  // Physical/Lifestyle
  String _diet = 'Vegetarian';
  String? _complexion, _bodyType, _exerciseHabit, _smokingHabit, _drinkingHabit;

  // Partner Preferences
  int _prefAgeMin = 20, _prefAgeMax = 35, _prefHeightMin = 150, _prefHeightMax = 185;
  String? _prefReligion, _prefCaste, _prefIncome, _prefDiet, _prefManglik;

  final _steps = const ['Basic', 'Cultural', 'Economic', 'Social', 'Mind', 'Lifestyle', 'Preferences'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Profile (${_currentStep + 1}/${_steps.length})'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_currentStep + 1) / _steps.length),
        ),
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildBasicStep(),
            _buildCulturalStep(),
            _buildEconomicStep(),
            _buildSocialStep(),
            _buildPsychologicalStep(),
            _buildLifestyleStep(),
            _buildPreferencesStep(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(child: OutlinedButton(onPressed: _prevStep, child: const Text('Back'))),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _loading ? null : (_currentStep == _steps.length - 1 ? _submit : _nextStep),
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_currentStep == _steps.length - 1 ? 'Upload (+3 Credits)' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 1: Basic Info
  Widget _buildBasicStep() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      _sectionTitle('Basic Information'),
      GestureDetector(
        onTap: _pickPhoto,
        child: Container(
          height: 80, decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
          child: Center(child: _photos.isEmpty
              ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, color: Colors.grey), SizedBox(width: 8), Text('Add Photos')])
              : Text('${_photos.length} photo(s) selected', style: const TextStyle(color: Colors.green))),
        ),
      ),
      const SizedBox(height: 12),
      TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
      const SizedBox(height: 12),
      _dropdown('Gender', _gender, ['Male', 'Female'], (v) => setState(() => _gender = v!)),
      _slider('Age', _age, 18, 60, (v) => setState(() => _age = v.round())),
      _slider('Height (cm)', _height, 140, 200, (v) => setState(() => _height = v.round())),
      TextFormField(controller: _cityController, decoration: const InputDecoration(labelText: 'City'), validator: (v) => v!.isEmpty ? 'Required' : null),
      const SizedBox(height: 8),
      _dropdown('State', _state, AppConstants.states, (v) => setState(() => _state = v!)),
    ]);
  }

  // Step 2: Cultural
  Widget _buildCulturalStep() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      _sectionTitle('Cultural Blueprint'),
      _dropdown('Religion', _religion, AppConstants.religions, (v) => setState(() => _religion = v!)),
      _dropdown('Caste', _caste, AppConstants.hinduCastes, (v) => setState(() => _caste = v!)),
      TextFormField(controller: _subCasteController, decoration: const InputDecoration(labelText: 'Sub-Caste (optional)')),
      const SizedBox(height: 8),
      TextFormField(controller: _gotraController, decoration: const InputDecoration(labelText: 'Gotra (optional)')),
      const SizedBox(height: 8),
      _dropdown('Manglik', _manglik, AppConstants.manglikOptions, (v) => setState(() => _manglik = v!)),
      _dropdown('Marital Status', _maritalStatus, AppConstants.maritalStatuses, (v) => setState(() => _maritalStatus = v!)),
    ]);
  }

  // Step 3: Economic
  Widget _buildEconomicStep() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      _sectionTitle('Financial Reality'),
      _dropdown('Education', _education, AppConstants.educationLevels, (v) => setState(() => _education = v!)),
      _dropdown('Profession', _profession, AppConstants.professions, (v) => setState(() => _profession = v!)),
      _dropdown('Personal Income', _income, AppConstants.incomeRanges, (v) => setState(() => _income = v!)),
      _dropdownNullable('Family Wealth', _familyWealth, AppConstants.familyWealthLevels, (v) => setState(() => _familyWealth = v)),
      _dropdownNullable('Family Annual Income', _familyIncome, AppConstants.familyIncomeRanges, (v) => setState(() => _familyIncome = v)),
      _dropdownNullable('Property Owned', _propertyOwned, AppConstants.propertyOptions, (v) => setState(() => _propertyOwned = v)),
    ]);
  }

  // Step 4: Social
  Widget _buildSocialStep() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      _sectionTitle('Social & Family'),
      _dropdown('Family Type', _familyType, AppConstants.familyTypes, (v) => setState(() => _familyType = v!)),
      TextFormField(controller: _fatherOccController, decoration: const InputDecoration(labelText: "Father's Occupation (optional)")),
      const SizedBox(height: 8),
      _dropdownNullable('Social Status', _socialStatus, AppConstants.socialStatuses, (v) => setState(() => _socialStatus = v)),
      _dropdownNullable('Family Values', _familyValues, AppConstants.familyValuesOptions, (v) => setState(() => _familyValues = v)),
      _dropdownNullable('Living Preference', _livingPreference, AppConstants.livingPreferences, (v) => setState(() => _livingPreference = v)),
      _dropdownNullable('Social Circle', _socialCircle, AppConstants.socialCircles, (v) => setState(() => _socialCircle = v)),
    ]);
  }

  // Step 5: Psychological
  Widget _buildPsychologicalStep() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      _sectionTitle('Personality & Mindset'),
      _dropdownNullable('Personality', _personality, AppConstants.personalities, (v) => setState(() => _personality = v)),
      _dropdownNullable('Temperament', _temperament, AppConstants.temperaments, (v) => setState(() => _temperament = v)),
      _dropdownNullable('Life Goals', _lifeGoals, AppConstants.lifeGoalOptions, (v) => setState(() => _lifeGoals = v)),
      _dropdownNullable('Communication Style', _communicationStyle, AppConstants.communicationStyles, (v) => setState(() => _communicationStyle = v)),
      _dropdownNullable('Political View', _politicalView, AppConstants.politicalViews, (v) => setState(() => _politicalView = v)),
      _dropdownNullable('Religious Level', _religiousLevel, AppConstants.religiousLevels, (v) => setState(() => _religiousLevel = v)),
    ]);
  }

  // Step 6: Lifestyle
  Widget _buildLifestyleStep() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      _sectionTitle('Lifestyle & Physical'),
      _dropdown('Diet', _diet, AppConstants.dietOptions, (v) => setState(() => _diet = v!)),
      _dropdownNullable('Complexion', _complexion, AppConstants.complexions, (v) => setState(() => _complexion = v)),
      _dropdownNullable('Body Type', _bodyType, AppConstants.bodyTypes, (v) => setState(() => _bodyType = v)),
      _dropdownNullable('Exercise Habit', _exerciseHabit, AppConstants.exerciseHabits, (v) => setState(() => _exerciseHabit = v)),
      _dropdownNullable('Smoking', _smokingHabit, AppConstants.smokingHabits, (v) => setState(() => _smokingHabit = v)),
      _dropdownNullable('Drinking', _drinkingHabit, AppConstants.drinkingHabits, (v) => setState(() => _drinkingHabit = v)),
    ]);
  }

  // Step 7: Partner Preferences
  Widget _buildPreferencesStep() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      _sectionTitle('Partner Preferences'),
      const Text('What are they looking for?', style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 12),
      _rangeSliderField('Preferred Age', _prefAgeMin, _prefAgeMax, 18, 60, (min, max) => setState(() { _prefAgeMin = min; _prefAgeMax = max; })),
      _rangeSliderField('Preferred Height (cm)', _prefHeightMin, _prefHeightMax, 140, 200, (min, max) => setState(() { _prefHeightMin = min; _prefHeightMax = max; })),
      _dropdownNullable('Preferred Religion', _prefReligion, AppConstants.religions, (v) => setState(() => _prefReligion = v)),
      _dropdownNullable('Preferred Caste', _prefCaste, AppConstants.hinduCastes, (v) => setState(() => _prefCaste = v)),
      _dropdownNullable('Preferred Income', _prefIncome, AppConstants.incomeRanges, (v) => setState(() => _prefIncome = v)),
      _dropdownNullable('Preferred Diet', _prefDiet, AppConstants.dietOptions, (v) => setState(() => _prefDiet = v)),
      _dropdownNullable('Preferred Manglik', _prefManglik, AppConstants.manglikOptions, (v) => setState(() => _prefManglik = v)),
    ]);
  }

  // Helpers
  Widget _sectionTitle(String t) => Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(t, style: Theme.of(context).textTheme.titleLarge));

  Widget _dropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: DropdownButtonFormField<String>(
      value: value, decoration: InputDecoration(labelText: label),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(), onChanged: onChanged,
    ));
  }

  Widget _dropdownNullable(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: DropdownButtonFormField<String>(
      value: value, decoration: InputDecoration(labelText: label),
      items: [const DropdownMenuItem(value: null, child: Text('Not specified')), ...items.map((i) => DropdownMenuItem(value: i, child: Text(i)))],
      onChanged: onChanged,
    ));
  }

  Widget _slider(String label, int value, double min, double max, ValueChanged<double> onChanged) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$label: $value'), Slider(value: value.toDouble(), min: min, max: max, divisions: (max - min).round(), onChanged: onChanged),
    ]));
  }

  Widget _rangeSliderField(String label, int min, int max, double rangeMin, double rangeMax, void Function(int, int) onChanged) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$label: $min - $max'),
      RangeSlider(values: RangeValues(min.toDouble(), max.toDouble()), min: rangeMin, max: rangeMax, divisions: (rangeMax - rangeMin).round(),
        labels: RangeLabels('$min', '$max'), onChanged: (v) => onChanged(v.start.round(), v.end.round())),
    ]));
  }

  void _nextStep() {
    if (_currentStep == 0 && !_formKey.currentState!.validate()) return;
    setState(() => _currentStep++);
    _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _prevStep() {
    setState(() => _currentStep--);
    _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<void> _pickPhoto() async {
    final images = await ImagePicker().pickMultiImage();
    if (images.isNotEmpty) setState(() => _photos.addAll(images));
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final scout = ref.read(currentScoutProvider);
      final service = ref.read(supabaseServiceProvider);
      final imageService = ImageService();

      List<String> photoUrls = [];
      if (_photos.isNotEmpty) {
        photoUrls = await imageService.uploadMultiple(scout?.id ?? 'unknown', _photos);
      }

      final profile = Profile(
        id: '', scoutId: scout?.id ?? '', name: _nameController.text.trim(),
        gender: _gender, age: _age, height: _height, religion: _religion, caste: _caste,
        subCaste: _subCasteController.text.trim().isEmpty ? null : _subCasteController.text.trim(),
        gotra: _gotraController.text.trim().isEmpty ? null : _gotraController.text.trim(),
        manglik: _manglik, education: _education, profession: _profession, income: _income,
        diet: _diet, maritalStatus: _maritalStatus, familyType: _familyType,
        fatherOccupation: _fatherOccController.text.trim().isEmpty ? null : _fatherOccController.text.trim(),
        city: _cityController.text.trim(), state: _state, complexion: _complexion, bodyType: _bodyType,
        photosUrl: photoUrls, createdAt: DateTime.now(),
        familyWealth: _familyWealth, propertyOwned: _propertyOwned, familyIncome: _familyIncome,
        socialStatus: _socialStatus, familyValues: _familyValues, livingPreference: _livingPreference,
        socialCircle: _socialCircle, personality: _personality, temperament: _temperament,
        lifeGoals: _lifeGoals, communicationStyle: _communicationStyle,
        politicalView: _politicalView, religiousLevel: _religiousLevel,
        exerciseHabit: _exerciseHabit, smokingHabit: _smokingHabit, drinkingHabit: _drinkingHabit,
        prefAgeMin: _prefAgeMin, prefAgeMax: _prefAgeMax, prefHeightMin: _prefHeightMin, prefHeightMax: _prefHeightMax,
        prefReligion: _prefReligion, prefCaste: _prefCaste, prefIncome: _prefIncome,
        prefDiet: _prefDiet, prefManglik: _prefManglik,
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
