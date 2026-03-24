import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../services/auth_service.dart';
import '../widgets/health_card.dart';
import 'analysis_screen.dart';
import 'diet_screen.dart';
import 'routine_screen.dart';
import 'progress_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user?.name ?? 'User'),
              const SizedBox(height: 24),
              _buildSummaryGrid(),
              const SizedBox(height: 32),
              _buildSectionTitle('Next Task'),
              const SizedBox(height: 12),
              _buildNextTaskCard(),
              const SizedBox(height: 32),
              _buildSectionTitle('Quick Actions'),
              const SizedBox(height: 12),
              _buildQuickActionsGrid(context),
              const SizedBox(height: 32),
              _buildSectionTitle('Recent Health Status'),
              const SizedBox(height: 12),
              _buildHealthStatusCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello, $name 👋', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis, maxLines: 1),
              const SizedBox(height: 4),
              const Text('Your health is looking good today!', style: TextStyle(fontSize: 13, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis, maxLines: 1),
            ],
          ),
        ),
        const SizedBox(width: 12),
        CircleAvatar(radius: 24, backgroundColor: AppColors.primaryLight, child: const Icon(Icons.person, color: AppColors.primary, size: 28)),
      ],
    );
  }

  Widget _buildSummaryGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: const [
        HealthCard(icon: Icons.local_fire_department, title: 'Calories', value: '1,840', unit: 'kcal', color: AppColors.error),
        HealthCard(icon: Icons.water_drop, title: 'Water', value: '1.2', unit: 'Liters', color: Colors.blue),
        HealthCard(icon: Icons.directions_run, title: 'Exercise', value: '45', unit: 'min', color: Colors.orange),
        HealthCard(icon: Icons.favorite, title: 'Health Score', value: '84', unit: '%', color: AppColors.success),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis)),
        TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(color: AppColors.primary))),
      ],
    );
  }

  Widget _buildNextTaskCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.lunch_dining, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lunch Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 4),
                Text('Quinoa Salad with Grilled Chicken', style: TextStyle(fontSize: 14, color: Colors.white70)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      {'title': 'Analysis', 'icon': Icons.analytics_outlined, 'color': Colors.purple, 'screen': const AnalysisScreen()},
      {'title': 'Diet', 'icon': Icons.restaurant_menu_outlined, 'color': Colors.green, 'screen': const DietScreen()},
      {'title': 'Routine', 'icon': Icons.calendar_today_outlined, 'color': Colors.blue, 'screen': const RoutineScreen()},
      {'title': 'Progress', 'icon': Icons.show_chart_outlined, 'color': Colors.orange, 'screen': const ProgressScreen()},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.5),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => action['screen'] as Widget)),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.1))),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: (action['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(action['icon'] as IconData, color: action['color'] as Color, size: 18)),
                const SizedBox(width: 8),
                Expanded(child: Text(action['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHealthStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle), child: const Icon(Icons.check_circle, color: AppColors.primary, size: 24)),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Health Score: 84/100', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text('You are in the top 15% users!', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}
