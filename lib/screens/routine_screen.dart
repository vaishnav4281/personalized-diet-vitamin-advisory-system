import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/routine_model.dart';
import '../widgets/loading_widget.dart';
import '../widgets/reminder_card.dart';
import '../widgets/custom_button.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'reminders_screen.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  _RoutineScreenState createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  bool _isLoading = true;
  Routine? _routine;

  @override
  void initState() {
    super.initState();
    _loadRoutine();
  }

  Future<void> _loadRoutine() async {
    setState(() => _isLoading = true);
    final api = ApiService();
    final storage = StorageService();
    final user = await storage.getUser();
    final token = await storage.getToken() ?? '';

    try {
      final response = await api.getRoutine(user?.id ?? '', token);
      if (response.isEmpty) {
        // 404 - no routine created yet, use demo data
        _loadDemoRoutine();
        return;
      }
      setState(() {
        _routine = Routine.fromJson(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _loadDemoRoutine();
    }
  }

  void _loadDemoRoutine() {
    setState(() {
      _routine = Routine(
        morning: [
          Activity(time: '07:00 AM', description: 'Wake up and drink 500ml warm water', icon: 'water_drop'),
          Activity(time: '07:30 AM', description: 'Morning Yoga and Stretching', icon: 'self_improvement'),
          Activity(time: '08:30 AM', description: 'Breakfast - High Protein', icon: 'restaurant'),
        ],
        afternoon: [
          Activity(time: '01:30 PM', description: 'Lunch - Low Carb Meal', icon: 'lunch_dining'),
          Activity(time: '03:00 PM', description: 'Quick Walk (15 mins)', icon: 'directions_walk'),
        ],
        evening: [
          Activity(time: '06:00 PM', description: 'Strength Training Workout', icon: 'fitness_center'),
          Activity(time: '07:30 PM', description: 'Dinner - Light Soup and Veggies', icon: 'soup_kitchen'),
        ],
        night: [
          Activity(time: '09:30 PM', description: 'Review progress and read 10 pages', icon: 'menu_book'),
          Activity(time: '10:30 PM', description: 'Sleep - Aim for 7-8 hours', icon: 'bedtime'),
        ],
        medications: ['Vitamin D3 - 1000 IU', 'Multivitamin'],
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading ? const LoadingWidget() : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildSection('Morning', _routine!.morning),
              _buildSection('Afternoon', _routine!.afternoon),
              _buildSection('Evening', _routine!.evening),
              _buildSection('Night', _routine!.night),
              const SizedBox(height: 32),
              _buildMedications(),
              const SizedBox(height: 48),
              Center(
                 child: CustomButton(
                   text: 'Manage Reminders',
                   width: 250,
                   isOutlined: true,
                   onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersScreen())),
                 ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Daily Routine', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text('Follow your personalized health schedule', style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildSection(String title, List<Activity> activities) {
    if (activities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(width: 8),
              const Expanded(child: Divider(color: AppColors.primaryLight, thickness: 1.5)),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final a = activities[index];
            return ReminderCard(
              title: a.description,
              time: a.time,
              category: title,
              isActive: !a.isCompleted,
              icon: _getIconForActivity(a.icon),
              onToggle: (v) => setState(() => a.isCompleted = !v),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMedications() {
    if (_routine!.medications.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [Icon(Icons.medication, color: AppColors.error), SizedBox(width: 12), Expanded(child: Text('Medications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis))]),
          const SizedBox(height: 20),
          ..._routine!.medications.map((m) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [const Icon(Icons.check_circle, color: AppColors.success, size: 20), const SizedBox(width: 12), Expanded(child: Text(m, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis))]))),
        ],
      ),
    );
  }

  IconData _getIconForActivity(String icon) {
    switch (icon) {
      case 'water_drop': return Icons.water_drop;
      case 'self_improvement': return Icons.self_improvement;
      case 'restaurant': return Icons.restaurant;
      case 'lunch_dining': return Icons.lunch_dining;
      case 'directions_walk': return Icons.directions_walk;
      case 'fitness_center': return Icons.fitness_center;
      case 'soup_kitchen': return Icons.soup_kitchen;
      case 'menu_book': return Icons.menu_book;
      case 'bedtime': return Icons.bedtime;
      default: return Icons.access_time;
    }
  }
}
