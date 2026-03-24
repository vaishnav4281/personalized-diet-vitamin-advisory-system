import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/diet_model.dart';
import '../widgets/meal_card.dart';
import '../widgets/loading_widget.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../widgets/custom_button.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  DietPlan? _dietPlan;
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _loadDiet();
  }

  Future<void> _loadDiet() async {
    setState(() => _isLoading = true);
    final api = ApiService();
    final storage = StorageService();
    final user = await storage.getUser();
    final token = await storage.getToken() ?? '';

    try {
      final response = await api.getDietPlan(user?.id ?? '', token);
      if (response.isEmpty) {
        // 404 - no diet plan created yet, use demo data
        _loadDemoDiet();
        return;
      }
      setState(() {
        _dietPlan = DietPlan.fromJson(response);
        _isLoading = false;
        // set tab to current day
        final dayIndex = DateTime.now().weekday - 1;
        _tabController.animateTo(dayIndex >= 0 ? dayIndex : 0);
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Fallback or demo data if backend fails
      _loadDemoDiet();
    }
  }

  void _loadDemoDiet() {
     // Create some demo data so the screen isn't empty
     Map<String, DayDiet> demo = {};
     for (var day in _days) {
       demo[day] = DayDiet(
         breakfast: [Meal(name: 'Oatmeal with Berries', calories: '320', proteins: '12g', carbs: '45g', fats: '8g')],
         lunch: [Meal(name: 'Grilled Chicken Salad', calories: '450', proteins: '35g', carbs: '15g', fats: '22g')],
         dinner: [Meal(name: 'Salmon with Asparagus', calories: '550', proteins: '40g', carbs: '10g', fats: '30g')],
         snacks: [Meal(name: 'Greek Yogurt', calories: '150', proteins: '15g', carbs: '10g', fats: '2g')],
         totalCalories: '1470',
       );
     }
     setState(() {
       _dietPlan = DietPlan(days: demo);
       _isLoading = false;
     });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Diet Plan', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: AppColors.primary), onPressed: _loadDiet),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: _days.map((day) => Tab(text: day.substring(0, 3))).toList(),
        ),
      ),
      body: _isLoading ? const LoadingWidget() : TabBarView(
        controller: _tabController,
        children: _days.map((day) => _buildDayView(day)).toList(),
      ),
    );
  }

  Widget _buildDayView(String day) {
    if (_dietPlan == null || !_dietPlan!.days.containsKey(day)) {
      return const Center(child: Text('No plan for this day'));
    }

    final plan = _dietPlan!.days[day]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDaySummary(plan),
          const SizedBox(height: 32),
          _buildMealSection('Breakfast', plan.breakfast),
          _buildMealSection('Lunch', plan.lunch),
          _buildMealSection('Dinner', plan.dinner),
          _buildMealSection('Snacks', plan.snacks),
          const SizedBox(height: 32),
          Center(
            child: CustomButton(
              text: 'Regenerate Plan',
              width: 200,
              isOutlined: true,
              onPressed: () {},
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDaySummary(DayDiet plan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daily Goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('${plan.totalCalories} kcal', style: const TextStyle(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: 0.65, backgroundColor: AppColors.primaryLight, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary), minHeight: 8),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroItem('Proteins', '85g', Colors.red),
              _buildMacroItem('Carbs', '160g', Colors.blue),
              _buildMacroItem('Fats', '55g', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildMealSection(String title, List<Meal> meals) {
    if (meals.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        ...meals.map((m) => MealCard(meal: m, onToggle: (v) => setState(() => m.isEaten = v ?? false))),
        const SizedBox(height: 16),
      ],
    );
  }
}
