import 'dart:convert';

class WorkoutExercise {
  WorkoutExercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.caloriesPerSet,
    required this.videoTitle,
    required this.videoUrl,
  });

  final String id;
  final String name;
  final int sets;
  final String reps;
  final int restSeconds;
  final int caloriesPerSet;
  final String videoTitle;
  final String videoUrl;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'sets': sets,
        'reps': reps,
        'restSeconds': restSeconds,
        'caloriesPerSet': caloriesPerSet,
        'videoTitle': videoTitle,
        'videoUrl': videoUrl,
      };

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) => WorkoutExercise(
        id: map['id'] as String,
        name: map['name'] as String,
        sets: map['sets'] as int,
        reps: map['reps'] as String,
        restSeconds: map['restSeconds'] as int,
        caloriesPerSet: map['caloriesPerSet'] as int,
        videoTitle: map['videoTitle'] as String,
        videoUrl: map['videoUrl'] as String,
      );
}

class WorkoutPlan {
  WorkoutPlan({
    required this.id,
    required this.name,
    required this.focus,
    required this.weekday,
    required this.exercises,
    required this.completedDates,
  });

  final String id;
  final String name;
  final String focus;
  final String weekday;
  final List<WorkoutExercise> exercises;
  final List<String> completedDates;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'focus': focus,
        'weekday': weekday,
        'exercises': exercises.map((e) => e.toMap()).toList(),
        'completedDates': completedDates,
      };

  factory WorkoutPlan.fromMap(Map<String, dynamic> map) => WorkoutPlan(
        id: map['id'] as String,
        name: map['name'] as String,
        focus: map['focus'] as String,
        weekday: map['weekday'] as String,
        exercises: (map['exercises'] as List<dynamic>)
            .map((e) => WorkoutExercise.fromMap(e as Map<String, dynamic>))
            .toList(),
        completedDates: List<String>.from(map['completedDates'] as List<dynamic>),
      );
}

class FoodEntry {
  FoodEntry({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.createdAt,
  });

  final String id;
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
        'createdAt': createdAt.toIso8601String(),
      };

  factory FoodEntry.fromMap(Map<String, dynamic> map) => FoodEntry(
        id: map['id'] as String,
        name: map['name'] as String,
        calories: map['calories'] as int,
        protein: map['protein'] as int,
        carbs: map['carbs'] as int,
        fats: map['fats'] as int,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}

class FoodAnalysis {
  FoodAnalysis({
    required this.id,
    required this.input,
    required this.detectedItems,
    required this.totalCalories,
    required this.notes,
  });

  final String id;
  final String input;
  final List<FoodEntry> detectedItems;
  final int totalCalories;
  final String notes;

  Map<String, dynamic> toMap() => {
        'id': id,
        'input': input,
        'detectedItems': detectedItems.map((e) => e.toMap()).toList(),
        'totalCalories': totalCalories,
        'notes': notes,
      };

  factory FoodAnalysis.fromMap(Map<String, dynamic> map) => FoodAnalysis(
        id: map['id'] as String,
        input: map['input'] as String,
        detectedItems: (map['detectedItems'] as List<dynamic>)
            .map((e) => FoodEntry.fromMap(e as Map<String, dynamic>))
            .toList(),
        totalCalories: map['totalCalories'] as int,
        notes: map['notes'] as String,
      );
}

class VideoResource {
  VideoResource({
    required this.id,
    required this.exerciseName,
    required this.title,
    required this.category,
    required this.url,
  });

  final String id;
  final String exerciseName;
  final String title;
  final String category;
  final String url;

  Map<String, dynamic> toMap() => {
        'id': id,
        'exerciseName': exerciseName,
        'title': title,
        'category': category,
        'url': url,
      };

  factory VideoResource.fromMap(Map<String, dynamic> map) => VideoResource(
        id: map['id'] as String,
        exerciseName: map['exerciseName'] as String,
        title: map['title'] as String,
        category: map['category'] as String,
        url: map['url'] as String,
      );
}

class StarterCreature {
  StarterCreature({
    required this.nickname,
    required this.species,
    required this.stage,
    required this.xp,
    required this.battlesWon,
  });

  final String nickname;
  final String species;
  final int stage;
  final int xp;
  final int battlesWon;

  Map<String, dynamic> toMap() => {
        'nickname': nickname,
        'species': species,
        'stage': stage,
        'xp': xp,
        'battlesWon': battlesWon,
      };

  factory StarterCreature.fromMap(Map<String, dynamic> map) => StarterCreature(
        nickname: map['nickname'] as String,
        species: map['species'] as String,
        stage: map['stage'] as int,
        xp: map['xp'] as int,
        battlesWon: map['battlesWon'] as int,
      );

  StarterCreature copyWith({
    String? nickname,
    String? species,
    int? stage,
    int? xp,
    int? battlesWon,
  }) {
    return StarterCreature(
      nickname: nickname ?? this.nickname,
      species: species ?? this.species,
      stage: stage ?? this.stage,
      xp: xp ?? this.xp,
      battlesWon: battlesWon ?? this.battlesWon,
    );
  }
}

class BattleLog {
  BattleLog({
    required this.id,
    required this.planName,
    required this.summary,
    required this.date,
  });

  final String id;
  final String planName;
  final String summary;
  final DateTime date;

  Map<String, dynamic> toMap() => {
        'id': id,
        'planName': planName,
        'summary': summary,
        'date': date.toIso8601String(),
      };

  factory BattleLog.fromMap(Map<String, dynamic> map) => BattleLog(
        id: map['id'] as String,
        planName: map['planName'] as String,
        summary: map['summary'] as String,
        date: DateTime.parse(map['date'] as String),
      );
}

class AppState {
  AppState({
    required this.workoutPlans,
    required this.foodEntries,
    required this.analyses,
    required this.videos,
    required this.todaySteps,
    required this.calorieGoal,
    required this.dailyTrainingDates,
    required this.starter,
    required this.capturedSpecies,
    required this.battleLogs,
  });

  final List<WorkoutPlan> workoutPlans;
  final List<FoodEntry> foodEntries;
  final List<FoodAnalysis> analyses;
  final List<VideoResource> videos;
  final int todaySteps;
  final int calorieGoal;
  final List<String> dailyTrainingDates;
  final StarterCreature starter;
  final List<String> capturedSpecies;
  final List<BattleLog> battleLogs;

  Map<String, dynamic> toMap() => {
        'workoutPlans': workoutPlans.map((e) => e.toMap()).toList(),
        'foodEntries': foodEntries.map((e) => e.toMap()).toList(),
        'analyses': analyses.map((e) => e.toMap()).toList(),
        'videos': videos.map((e) => e.toMap()).toList(),
        'todaySteps': todaySteps,
        'calorieGoal': calorieGoal,
        'dailyTrainingDates': dailyTrainingDates,
        'starter': starter.toMap(),
        'capturedSpecies': capturedSpecies,
        'battleLogs': battleLogs.map((e) => e.toMap()).toList(),
      };

  factory AppState.fromJson(String value) {
    final map = jsonDecode(value) as Map<String, dynamic>;
    return AppState(
      workoutPlans: (map['workoutPlans'] as List<dynamic>)
          .map((e) => WorkoutPlan.fromMap(e as Map<String, dynamic>))
          .toList(),
      foodEntries: (map['foodEntries'] as List<dynamic>)
          .map((e) => FoodEntry.fromMap(e as Map<String, dynamic>))
          .toList(),
      analyses: (map['analyses'] as List<dynamic>)
          .map((e) => FoodAnalysis.fromMap(e as Map<String, dynamic>))
          .toList(),
      videos: (map['videos'] as List<dynamic>)
          .map((e) => VideoResource.fromMap(e as Map<String, dynamic>))
          .toList(),
      todaySteps: map['todaySteps'] as int,
      calorieGoal: map['calorieGoal'] as int,
      dailyTrainingDates: List<String>.from(map['dailyTrainingDates'] as List<dynamic>),
      starter: StarterCreature.fromMap(map['starter'] as Map<String, dynamic>),
      capturedSpecies: List<String>.from(map['capturedSpecies'] as List<dynamic>),
      battleLogs: (map['battleLogs'] as List<dynamic>)
          .map((e) => BattleLog.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  String toJson() => jsonEncode(toMap());
}
