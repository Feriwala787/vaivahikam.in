import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/app_providers.dart';

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key});

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late String? _gender, _religion, _caste, _manglik, _education, _profession, _income, _diet, _maritalStatus, _state;
  late RangeValues _ageRange, _heightRange;

  @override
  void initState() {
    super.initState();
    final f = ref.read(matchFilterProvider);
    _gender = f.gender;
    _religion = f.religion;
    _caste = f.caste;
    _manglik = f.manglik;
    _education = f.education;
    _profession = f.profession;
    _income = f.income;
    _diet = f.diet;
    _maritalStatus = f.maritalStatus;
    _state = f.state;
    _ageRange = RangeValues((f.ageMin ?? 18).toDouble(), (f.ageMax ?? 45).toDouble());
    _heightRange = RangeValues((f.heightMin ?? 140).toDouble(), (f.heightMax ?? 200).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          controller: controller,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Advanced Filters', style: Theme.of(context).textTheme.titleLarge),
                TextButton(onPressed: _clearAll, child: const Text('Clear All')),
              ],
            ),
            const Divider(),
            // Gender
            _buildDropdown('Gender', _gender, ['Male', 'Female'], (v) => setState(() => _gender = v)),
            // Age Range
            _buildRangeSection('Age', _ageRange, 18, 60, (v) => setState(() => _ageRange = v)),
            // Height Range
            _buildRangeSection('Height (cm)', _heightRange, 140, 200, (v) => setState(() => _heightRange = v)),
            // Religion
            _buildDropdown('Religion', _religion, AppConstants.religions, (v) => setState(() => _religion = v)),
            // Caste
            _buildDropdown('Caste', _caste, AppConstants.hinduCastes, (v) => setState(() => _caste = v)),
            // Manglik
            _buildDropdown('Manglik', _manglik, AppConstants.manglikOptions, (v) => setState(() => _manglik = v)),
            // Education
            _buildDropdown('Education', _education, AppConstants.educationLevels, (v) => setState(() => _education = v)),
            // Profession
            _buildDropdown('Profession', _profession, AppConstants.professions, (v) => setState(() => _profession = v)),
            // Income
            _buildDropdown('Income', _income, AppConstants.incomeRanges, (v) => setState(() => _income = v)),
            // Diet
            _buildDropdown('Diet', _diet, AppConstants.dietOptions, (v) => setState(() => _diet = v)),
            // Marital Status
            _buildDropdown('Marital Status', _maritalStatus, AppConstants.maritalStatuses, (v) => setState(() => _maritalStatus = v)),
            // State
            _buildDropdown('State', _state, AppConstants.states, (v) => setState(() => _state = v)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _applyFilters,
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Text('Apply Filters', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: [
          const DropdownMenuItem(value: null, child: Text('Any')),
          ...options.map((o) => DropdownMenuItem(value: o, child: Text(o))),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildRangeSection(String label, RangeValues range, double min, double max, ValueChanged<RangeValues> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ${range.start.round()} - ${range.end.round()}'),
          RangeSlider(
            values: range,
            min: min,
            max: max,
            divisions: (max - min).round(),
            labels: RangeLabels('${range.start.round()}', '${range.end.round()}'),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _clearAll() {
    setState(() {
      _gender = _religion = _caste = _manglik = _education = _profession = _income = _diet = _maritalStatus = _state = null;
      _ageRange = const RangeValues(18, 45);
      _heightRange = const RangeValues(140, 200);
    });
  }

  void _applyFilters() {
    ref.read(matchFilterProvider.notifier).updateFilter(
      ref.read(matchFilterProvider).copyWith(
        gender: _gender,
        religion: _religion,
        caste: _caste,
        manglik: _manglik,
        education: _education,
        profession: _profession,
        income: _income,
        diet: _diet,
        maritalStatus: _maritalStatus,
        state: _state,
        ageMin: _ageRange.start.round(),
        ageMax: _ageRange.end.round(),
        heightMin: _heightRange.start.round(),
        heightMax: _heightRange.end.round(),
      ),
    );
    Navigator.pop(context);
  }
}
