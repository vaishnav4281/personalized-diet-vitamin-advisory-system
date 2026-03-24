import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'splash_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1: Metrics
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String _gender = 'Male';

  // Step 2: Preferences
  String _activityLevel = 'Sedentary';
  String _foodPref = 'Veg';
  final _allergiesController = TextEditingController();

  // Step 3: Goals
  String _goal = 'Weight Loss';

  // Step 4: Medications
  final _medsController = TextEditingController();

  double get _bmi {
    final h = double.tryParse(_heightController.text) ?? 0;
    final w = double.tryParse(_weightController.text) ?? 0;
    if (h > 0 && w > 0) {
      // height in cm to m
      final hm = h / 100;
      return w / (hm * hm);
    }
    return 0;
  }

  void _nextPage() {
    if (_currentStep < 3) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
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
      'bmi': _bmi,
      'activity_level': _activityLevel,
      'food_preference': _foodPref,
      'allergies': _allergiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      'health_goals': _goal,
      'medications': _medsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
    };

    try {
      await api.saveOnboarding(data, token);
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainAppPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: List.generate(4, (index) => Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index <= _currentStep ? AppColors.primary : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentStep = i),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                   if (_currentStep > 0)
                    Expanded(
                      child: CustomButton(
                        text: 'Back',
                        isOutlined: true,
                        onPressed: () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: _currentStep == 3 ? 'Finish' : 'Next',
                      isLoading: _isLoading,
                      onPressed: _nextPage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Basic Info', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Help us calculate your health baseline', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          CustomTextField(label: 'Age', controller: _ageController, keyboardType: TextInputType.number),
          const SizedBox(height: 24),
          const Text('Gender', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: ['Male', 'Female', 'Other'].map((g) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(g),
                  selected: _gender == g,
                  onSelected: (s) => setState(() => _gender = g),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(color: _gender == g ? Colors.white : AppColors.textPrimary),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: CustomTextField(label: 'Height (cm)', controller: _heightController, keyboardType: TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(child: CustomTextField(label: 'Weight (kg)', controller: _weightController, keyboardType: TextInputType.number)),
            ],
          ),
          if (_bmi > 0) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.speed, color: AppColors.primary),
                  const SizedBox(width: 16),
                  Text('Estimated BMI: ${_bmi.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lifestyle', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Tell us about your habits', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          const Text('Activity Level', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _activityLevel,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
            items: ['Sedentary', 'Lightly Active', 'Moderately Active', 'Very Active'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _activityLevel = v!),
          ),
          const SizedBox(height: 24),
          const Text('Food Preference', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: ['Veg', 'Non-Veg', 'Vegan'].map((f) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(f),
                  selected: _foodPref == f,
                  onSelected: (s) => setState(() => _foodPref = f),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(color: _foodPref == f ? Colors.white : AppColors.textPrimary),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 24),
          CustomTextField(label: 'Allergies (comma separated)', hint: 'e.g. Peanuts, Milk', controller: _allergiesController),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Health Goals', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('What do you want to achieve?', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          ...['Weight Loss', 'Muscle Gain', 'Improve Energy', 'Better Sleep', 'General Fitness'].map((g) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RadioListTile<String>(
              title: Text(g),
              value: g,
              groupValue: _goal,
              onChanged: (v) => setState(() => _goal = v!),
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: _goal == g ? AppColors.primary : Colors.grey.shade300)),
              tileColor: Colors.white,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Medications', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Any current prescriptions?', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          CustomTextField(
            label: 'Medications (comma separated)',
            hint: 'e.g. Metformin, Vitamin D',
            controller: _medsController,
          ),
          const SizedBox(height: 16),
          const Text('Note: This helps us tailor your routine and diet safely.', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
