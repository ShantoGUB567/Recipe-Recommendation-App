class UserProfile {
  final String uid;
  final String age;
  final String gender; // Male, Female, Other
  final String height; // in cm
  final String weight; // in kg
  final String activityLevel; // Sedentary, Lightly Active, Moderately Active, Very Active
  final String primaryGoal; // Weight Loss, Muscle Gain, Maintenance
  final List<String> dietaryPreferences; // Vegan, Keto, Paleo, Standard
  final List<String> allergies; // List of allergies
  final List<String> medicalConditions; // List of medical conditions
  final int? calorieGoal; // Calculated based on metrics
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.primaryGoal,
    required this.dietaryPreferences,
    required this.allergies,
    required this.medicalConditions,
    this.calorieGoal,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate calorie goal based on body metrics and activity level
  int calculateCalorieGoal() {
    try {
      final w = double.parse(weight);
      final h = double.parse(height);
      final a = int.parse(age);

      // Simplified BMR calculation (Mifflin-St Jeor)
      double bmr = (10 * w) + (6.25 * h) - (5 * a) + 5; // Default male

      // Activity level multiplier
      double activityMultiplier = 1.2;
      switch (activityLevel) {
        case 'Sedentary':
          activityMultiplier = 1.2;
          break;
        case 'Lightly Active':
          activityMultiplier = 1.375;
          break;
        case 'Moderately Active':
          activityMultiplier = 1.55;
          break;
        case 'Very Active':
          activityMultiplier = 1.725;
          break;
      }

      double tdee = bmr * activityMultiplier;

      // Adjust based on primary goal
      switch (primaryGoal) {
        case 'Weight Loss':
          return (tdee * 0.85).toInt(); // 15% deficit
        case 'Muscle Gain':
          return (tdee * 1.1).toInt(); // 10% surplus
        case 'Maintenance':
          return tdee.toInt();
        default:
          return tdee.toInt();
      }
    } catch (e) {
      return 2000; // Default fallback
    }
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'activityLevel': activityLevel,
      'primaryGoal': primaryGoal,
      'dietaryPreferences': dietaryPreferences,
      'allergies': allergies,
      'medicalConditions': medicalConditions,
      'calorieGoal': calorieGoal ?? calculateCalorieGoal(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create from JSON (Firestore)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] ?? '',
      age: json['age'] ?? '',
      gender: json['gender'] ?? '',
      height: json['height'] ?? '',
      weight: json['weight'] ?? '',
      activityLevel: json['activityLevel'] ?? '',
      primaryGoal: json['primaryGoal'] ?? '',
      dietaryPreferences: List<String>.from(json['dietaryPreferences'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      medicalConditions: List<String>.from(json['medicalConditions'] ?? []),
      calorieGoal: json['calorieGoal'],
      createdAt: json['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: json['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  // Copy with modifications
  UserProfile copyWith({
    String? uid,
    String? age,
    String? gender,
    String? height,
    String? weight,
    String? activityLevel,
    String? primaryGoal,
    List<String>? dietaryPreferences,
    List<String>? allergies,
    List<String>? medicalConditions,
    int? calorieGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      activityLevel: activityLevel ?? this.activityLevel,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      allergies: allergies ?? this.allergies,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
