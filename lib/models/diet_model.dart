class Meal {
  final String name;
  final String calories;
  final String proteins;
  final String carbs;
  final String fats;
  bool isEaten;

  Meal({
    required this.name,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    this.isEaten = false,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['name'] ?? '',
      calories: json['calories']?.toString() ?? '0 kcal',
      proteins: json['proteins']?.toString() ?? '0g',
      carbs: json['carbs']?.toString() ?? '0g',
      fats: json['fats']?.toString() ?? '0g',
      isEaten: json['is_eaten'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      'is_eaten': isEaten,
    };
  }
}

class DayDiet {
  final List<Meal> breakfast;
  final List<Meal> lunch;
  final List<Meal> dinner;
  final List<Meal> snacks;
  final String totalCalories;

  DayDiet({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snacks,
    required this.totalCalories,
  });

  factory DayDiet.fromJson(Map<String, dynamic> json) {
    return DayDiet(
      breakfast: (json['breakfast'] as List?)?.map((m) => Meal.fromJson(m)).toList() ?? [],
      lunch: (json['lunch'] as List?)?.map((m) => Meal.fromJson(m)).toList() ?? [],
      dinner: (json['dinner'] as List?)?.map((m) => Meal.fromJson(m)).toList() ?? [],
      snacks: (json['snacks'] as List?)?.map((m) => Meal.fromJson(m)).toList() ?? [],
      totalCalories: json['total_calories']?.toString() ?? '0',
    );
  }
}

class DietPlan {
  final Map<String, DayDiet> days;

  DietPlan({required this.days});

  factory DietPlan.fromJson(Map<String, dynamic> json) {
    Map<String, DayDiet> days = {};
    final dayNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    
    for (var day in dayNames) {
      if (json.containsKey(day)) {
        days[day] = DayDiet.fromJson(json[day]);
      }
    }
    
    // In case back-end uses lowercase
    if (days.isEmpty) {
      for (var day in dayNames) {
        String lowerDay = day.toLowerCase();
        if (json.containsKey(lowerDay)) {
          days[day] = DayDiet.fromJson(json[lowerDay]);
        }
      }
    }
    
    return DietPlan(days: days);
  }
}
