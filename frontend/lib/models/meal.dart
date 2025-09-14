class Meal {
  final String id;
  final String imagePath;
  final String? imageUrl;
  final String? comments;
  final double calories;
  final DateTime createdAt;
  final String? geminiAnalysis;

  Meal({
    required this.id,
    required this.imagePath,
    this.imageUrl,
    this.comments,
    required this.calories,
    required this.createdAt,
    this.geminiAnalysis,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      imagePath: json['image_path'] ?? '',
      imageUrl: json['image_url'],
      comments: json['comments'],
      calories: (json['calories'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      geminiAnalysis: json['gemini_analysis'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_path': imagePath,
      'image_url': imageUrl,
      'comments': comments,
      'calories': calories,
      'created_at': createdAt.toIso8601String(),
      'gemini_analysis': geminiAnalysis,
    };
  }
}
