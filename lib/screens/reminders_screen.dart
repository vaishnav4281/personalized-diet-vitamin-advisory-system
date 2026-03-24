import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/reminder_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  _RemindersScreenState createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final List<Map<String, dynamic>> _reminders = [
    {'title': 'Morning Water', 'time': '07:00 AM', 'category': 'Habit', 'isActive': true, 'icon': Icons.water_drop},
    {'title': 'Breakfast', 'time': '08:30 AM', 'category': 'Meal', 'isActive': true, 'icon': Icons.restaurant},
    {'title': 'Vitamin D', 'time': '09:00 AM', 'category': 'Medicine', 'isActive': false, 'icon': Icons.medication},
    {'title': 'Mid-day Walk', 'time': '01:00 PM', 'category': 'Exercise', 'isActive': true, 'icon': Icons.directions_walk},
  ];

  void _showAddReminderSheet() {
    final titleController = TextEditingController();
    final timeController = TextEditingController();
    String category = 'Custom';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add New Reminder', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              CustomTextField(label: 'Remind me about', hint: 'e.g. Yoga', controller: titleController),
              const SizedBox(height: 20),
              Row(
                children: [
                   Expanded(child: CustomTextField(label: 'Time', hint: '08:00 AM', controller: timeController)),
                   const SizedBox(width: 16),
                   Expanded(child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                        const Text('Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: category,
                          items: ['Custom', 'Meal', 'Medicine', 'Exercise'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => category = v!,
                          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                        ),
                     ],
                   )),
                ],
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Schedule Reminder',
                onPressed: () {
                   setState(() {
                     _reminders.add({'title': titleController.text, 'time': timeController.text, 'category': category, 'isActive': true, 'icon': Icons.notifications});
                   });
                   Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Reminders', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final r = _reminders[index];
          return ReminderCard(
            title: r['title'],
            time: r['time'],
            category: r['category'],
            isActive: r['isActive'],
            icon: r['icon'],
            onToggle: (v) => setState(() => r['isActive'] = v),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderSheet,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
