class Deficiency {
  final String title;
  final String severity;
  final List<String> foods;
  final String description;

  Deficiency({
    required this.title,
    required this.severity,
    required this.foods,
    required this.description,
  });

  factory Deficiency.fromJson(Map<String, dynamic> json) {
    return Deficiency(
      title: json['title'] ?? '',
      severity: json['severity'] ?? '',
      foods: List<String>.from(json['recommended_foods'] ?? []),
      description: json['description'] ?? '',
    );
  }
}

class AnalysisResult {
  final double score;
  final double bmi;
  final String bmiCategory;
  final List<Deficiency> deficiencies;
  final List<String> foodRecommendations;
  final List<String> lifestyleAdvice;
  final String summary;

  AnalysisResult({
    required this.score,
    required this.bmi,
    required this.bmiCategory,
    required this.deficiencies,
    required this.foodRecommendations,
    required this.lifestyleAdvice,
    required this.summary,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      bmi: (json['bmi'] as num?)?.toDouble() ?? 0.0,
      bmiCategory: json['bmi_category'] ?? '',
      deficiencies: (json['deficiencies'] as List?)
              ?.map((d) => Deficiency.fromJson(d))
              .toList() ??
          [],
      foodRecommendations: List<String>.from(json['recommended_foods'] ?? []),
      lifestyleAdvice: List<String>.from(json['lifestyle_advice'] ?? []),
      summary: json['summary'] ?? '',
    );
  }
}
