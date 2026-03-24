import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_widget.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/analysis_model.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  AnalysisResult? _result;

  // Form State
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final String _gender = 'Male';
  
  final List<String> _symptoms = [
    'Hair Fall', 'Fatigue', 'Dandruff', 'Dry Skin', 'Weak Nails', 'Night Blindness',
    'Bleeding Gums', 'Skin Irritation', 'Digestion Issues', 'Bone Pain',
    'Weakness', 'Pale Skin', 'Mouth Ulcers', 'Muscle Cramps', 'Depression',
    'Poor Concentration', 'Insomnia', 'Anxiety', 'Acne', 'Back Pain'
  ];
  final Set<String> _selectedSymptoms = {};

  final _bpController = TextEditingController();
  final _sugarController = TextEditingController();
  final _hemoglobinController = TextEditingController();

  String _dietPref = 'Veg';
  String _goal = 'General Fitness';

  Future<void> _submitAnalysis() async {
    setState(() => _isLoading = true);
    final api = ApiService();
    final storage = StorageService();
    final token = await storage.getToken() ?? '';
    final userId = await storage.getUserId() ?? '';

    final data = {
      'user_id': int.tryParse(userId) ?? userId,
      'age': int.tryParse(_ageController.text),
      'gender': _gender,
      'height': double.tryParse(_heightController.text),
      'weight': double.tryParse(_weightController.text),
      'symptoms': _selectedSymptoms.toList(),
      'blood_pressure': _bpController.text,
      'blood_sugar': _sugarController.text,
      'hemoglobin': _hemoglobinController.text,
      'diet_preference': _dietPref,
      'goal': _goal,
    };

    try {
      final response = await api.analyzeHealth(data, token);
      setState(() {
        _result = AnalysisResult.fromJson(response);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString(), style: const TextStyle(color: Colors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_result != null) return _buildResultsView();

    return Scaffold(
      appBar: AppBar(title: const Text('Health Analysis', style: TextStyle(color: AppColors.textPrimary)), backgroundColor: AppColors.background, elevation: 0),
      body: _isLoading ? const LoadingWidget(message: 'Analyzing your health data...') : Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() => _currentStep++);
          } else {
            _submitAnalysis();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: Row(
              children: [
                if (_currentStep > 0) Expanded(child: CustomButton(text: 'Back', isOutlined: true, onPressed: details.onStepCancel!)),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(child: CustomButton(text: _currentStep == 3 ? 'Analyze Now' : 'Continue', onPressed: details.onStepContinue!)),
              ],
            ),
          );
        },
        steps: [
          Step(title: const Text('Metrics'), content: _buildStep1(), isActive: _currentStep >= 0),
          Step(title: const Text('Symptoms'), content: _buildStep2(), isActive: _currentStep >= 1),
          Step(title: const Text('Labs'), content: _buildStep3(), isActive: _currentStep >= 2),
          Step(title: const Text('Goals'), content: _buildStep4(), isActive: _currentStep >= 3),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        CustomTextField(label: 'Age', controller: _ageController, keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: CustomTextField(label: 'Height (cm)', controller: _heightController, keyboardType: TextInputType.number)),
            const SizedBox(width: 16),
            Expanded(child: CustomTextField(label: 'Weight (kg)', controller: _weightController, keyboardType: TextInputType.number)),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select symptoms you are experiencing:', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _symptoms.map((s) => FilterChip(
            label: Text(s),
            selected: _selectedSymptoms.contains(s),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedSymptoms.add(s);
                } else {
                  _selectedSymptoms.remove(s);
                }
              });
            },
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(color: _selectedSymptoms.contains(s) ? Colors.white : AppColors.textPrimary, fontSize: 12),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        CustomTextField(label: 'Blood Pressure (e.g. 120/80)', controller: _bpController),
        const SizedBox(height: 16),
        CustomTextField(label: 'Blood Sugar (mg/dL)', controller: _sugarController, keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        CustomTextField(label: 'Hemoglobin (g/dL)', controller: _hemoglobinController, keyboardType: TextInputType.number),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      children: [
        const Text('Diet Preference', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _dietPref,
          items: ['Veg', 'Non-Veg', 'Vegan'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => _dietPref = v!,
          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
        ),
        const SizedBox(height: 24),
        const Text('Health Goal', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _goal,
          items: ['Weight Loss', 'Muscle Gain', 'Improve Energy', 'General Fitness'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => _goal = v!,
          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
        ),
      ],
    );
  }

  Widget _buildResultsView() {
    final res = _result!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Analysis Results'), leading: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _result = null))),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(child: CustomButton(text: 'Generate Diet', isOutlined: true, onPressed: () {})),
            const SizedBox(width: 16),
            Expanded(child: CustomButton(text: 'Generate Routine', onPressed: () {})),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 6)),
                child: Center(child: Text('${res.score.toInt()}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary))),
              ),
            ),
            const SizedBox(height: 16),
            const Center(child: Text('Your Health Score', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            const SizedBox(height: 32),
            _buildResultCard('BMI Index', '${res.bmi.toStringAsFixed(1)} (${res.bmiCategory})', Icons.speed),
            const SizedBox(height: 16),
            if (res.deficiencies.isNotEmpty) ...[
              const Text('Potential Deficiencies', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...res.deficiencies.map((d) => _buildDeficiencyCard(d)),
            ],
            const SizedBox(height: 24),
            const Text('Lifestyle Advice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...res.lifestyleAdvice.map((a) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 20), const SizedBox(width: 12), Expanded(child: Text(a))]))),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String title, String val, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)), Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)])),
        ],
      ),
    );
  }

  Widget _buildDeficiencyCard(Deficiency d) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(d.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: d.severity == 'High' ? AppColors.error.withOpacity(0.1) : AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(d.severity, style: TextStyle(color: d.severity == 'High' ? AppColors.error : AppColors.warning, fontSize: 10, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 8),
          Text(d.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          const Text('Recommended Foods:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Wrap(spacing: 8, children: d.foods.map((f) => Chip(label: Text(f, style: const TextStyle(fontSize: 10)), backgroundColor: AppColors.primaryLight, padding: EdgeInsets.zero)).toList()),
        ],
      ),
    );
  }
}
