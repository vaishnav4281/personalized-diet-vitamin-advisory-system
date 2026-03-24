import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/colors.dart';
import '../widgets/custom_button.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _waterGlasses = 3;
  String _selectedMood = 'Happy';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Your Progress', style: TextStyle(color: AppColors.textPrimary)), backgroundColor: AppColors.background, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeeklyChart(),
            const SizedBox(height: 32),
            _buildWaterIntake(),
            const SizedBox(height: 32),
            _buildMoodSelector(),
            const SizedBox(height: 32),
            _buildWeightLog(),
            const SizedBox(height: 48),
            CustomButton(text: 'Save Today\'s Progress', onPressed: () {}),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 250,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Health Score Trend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: true, rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 4,
                    dotData: FlDotData(show: true),
                    spots: const [FlSpot(0, 65), FlSpot(1, 70), FlSpot(2, 62), FlSpot(3, 80), FlSpot(4, 75), FlSpot(5, 84), FlSpot(6, 82)],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterIntake() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Water Hydration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('$_waterGlasses / 8 Glasses', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(8, (index) => GestureDetector(
              onTap: () => setState(() => _waterGlasses = index + 1),
              child: Icon(
                Icons.water_drop,
                color: index < _waterGlasses ? Colors.blue : Colors.grey.withOpacity(0.3),
                size: 24,
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    final moods = [
      {'label': 'Great', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.green},
      {'label': 'Happy', 'icon': Icons.sentiment_satisfied, 'color': Colors.lightGreen},
      {'label': 'Neutral', 'icon': Icons.sentiment_neutral, 'color': Colors.orange},
      {'label': 'Bad', 'icon': Icons.sentiment_dissatisfied, 'color': Colors.deepOrange},
      {'label': 'Awful', 'icon': Icons.sentiment_very_dissatisfied, 'color': Colors.red},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mood of the Day', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.spaceAround,
            children: moods.map((m) => GestureDetector(
              onTap: () => setState(() => _selectedMood = m['label'] as String),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(m['icon'] as IconData, color: _selectedMood == m['label'] ? m['color'] as Color : Colors.grey.withOpacity(0.4), size: 28),
                  const SizedBox(height: 4),
                  Text(m['label'] as String, style: TextStyle(fontSize: 10, color: _selectedMood == m['label'] ? AppColors.textPrimary : AppColors.textSecondary)),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightLog() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Weight', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                SizedBox(height: 4),
                Text('Last log: 2 days ago', style: TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
            child: const Text('72.5 kg', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18)),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.edit, color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }
}
