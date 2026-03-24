class Activity {
  final String time;
  final String description;
  final String icon;
  bool isCompleted;

  Activity({
    required this.time,
    required this.description,
    required this.icon,
    this.isCompleted = false,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      time: json['time'] ?? '00:00',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'circle_outlined',
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'description': description,
      'icon': icon,
      'is_completed': isCompleted,
    };
  }
}

class Routine {
  final List<Activity> morning;
  final List<Activity> afternoon;
  final List<Activity> evening;
  final List<Activity> night;
  final List<String> medications;

  Routine({
    required this.morning,
    required this.afternoon,
    required this.evening,
    required this.night,
    required this.medications,
  });

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      morning: (json['morning'] as List?)?.map((a) => Activity.fromJson(a)).toList() ?? [],
      afternoon: (json['afternoon'] as List?)?.map((a) => Activity.fromJson(a)).toList() ?? [],
      evening: (json['evening'] as List?)?.map((a) => Activity.fromJson(a)).toList() ?? [],
      night: (json['night'] as List?)?.map((a) => Activity.fromJson(a)).toList() ?? [],
      medications: List<String>.from(json['medications'] ?? []),
    );
  }
}
