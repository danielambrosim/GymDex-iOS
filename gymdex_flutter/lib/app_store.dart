import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class AppStore extends ChangeNotifier {
  static const _storageKey = 'gymdex_flutter_state';

  AppState _state = _defaultState();

  AppState get state => _state;

  int get todayCaloriesConsumed {
    final now = DateTime.now();
    return _state.foodEntries
        .where((entry) =>
            entry.createdAt.year == now.year &&
            entry.createdAt.month == now.month &&
            entry.createdAt.day == now.day)
        .fold(0, (sum, entry) => sum + entry.calories);
  }

  int get todayWorkoutCalories {
    return _state.workoutPlans
        .where((plan) => plan.completedDates.contains(_todayKey))
        .fold(0, (sum, plan) {
      final total = plan.exercises.fold<int>(
        0,
        (exerciseSum, item) => exerciseSum + item.sets * item.caloriesPerSet,
      );
      return sum + total;
    });
  }

  int get totalCaloriesBurned => todayWorkoutCalories + (_state.todaySteps * 0.04).round();

  int get netCalories => todayCaloriesConsumed - totalCaloriesBurned;

  int get trainingStreak {
    var streak = 0;
    var day = DateTime.now();
    while (_state.dailyTrainingDates.contains(_dateKey(day))) {
      streak += 1;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey);
    if (saved != null && saved.isNotEmpty) {
      _state = AppState.fromJson(saved);
    }
    notifyListeners();
  }

  Future<void> addWorkoutPlan(String name, String focus, String weekday) async {
    final plans = List<WorkoutPlan>.from(_state.workoutPlans)
      ..add(
        WorkoutPlan(
          id: _id(),
          name: name,
          focus: focus,
          weekday: weekday,
          exercises: [],
          completedDates: [],
        ),
      );
    _state = _copyWith(workoutPlans: plans);
    await _persist();
  }

  Future<void> addExercise(
    String planId,
    WorkoutExercise exercise,
  ) async {
    final plans = _state.workoutPlans.map((plan) {
      if (plan.id != planId) return plan;
      return WorkoutPlan(
        id: plan.id,
        name: plan.name,
        focus: plan.focus,
        weekday: plan.weekday,
        exercises: [...plan.exercises, exercise],
        completedDates: plan.completedDates,
      );
    }).toList();

    final videos = List<VideoResource>.from(_state.videos)
      ..add(
        VideoResource(
          id: _id(),
          exerciseName: exercise.name,
          title: exercise.videoTitle,
          category: 'Treino',
          url: exercise.videoUrl,
        ),
      );

    _state = _copyWith(workoutPlans: plans, videos: videos);
    await _persist();
  }

  Future<void> completeWorkout(String planId) async {
    final plans = _state.workoutPlans.map((plan) {
      if (plan.id != planId || plan.completedDates.contains(_todayKey)) return plan;
      return WorkoutPlan(
        id: plan.id,
        name: plan.name,
        focus: plan.focus,
        weekday: plan.weekday,
        exercises: plan.exercises,
        completedDates: [...plan.completedDates, _todayKey],
      );
    }).toList();

    final alreadyTrained = _state.dailyTrainingDates.contains(_todayKey);
    final dates = alreadyTrained
        ? List<String>.from(_state.dailyTrainingDates)
        : [..._state.dailyTrainingDates, _todayKey];

    final evolvedStarter = _evolve(
      _state.starter.copyWith(
        xp: _state.starter.xp + 35,
        battlesWon: _state.starter.battlesWon + 1,
      ),
    );

    final currentPlan = _state.workoutPlans.firstWhere((plan) => plan.id == planId);
    final battles = [
      BattleLog(
        id: _id(),
        planName: currentPlan.name,
        summary: '${evolvedStarter.nickname} venceu uma batalha apos o treino ${currentPlan.name}.',
        date: DateTime.now(),
      ),
      ..._state.battleLogs,
    ];

    _state = _copyWith(
      workoutPlans: plans,
      dailyTrainingDates: dates,
      starter: evolvedStarter,
      battleLogs: battles,
    );
    await _persist();
  }

  Future<void> addFood(String name, int calories, int protein, int carbs, int fats) async {
    final foods = [
      FoodEntry(
        id: _id(),
        name: name,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fats: fats,
        createdAt: DateTime.now(),
      ),
      ..._state.foodEntries,
    ];
    _state = _copyWith(foodEntries: foods);
    await _persist();
  }

  Future<void> updateSteps(int value) async {
    _state = _copyWith(todaySteps: value);
    await _persist();
  }

  Future<FoodAnalysis> analyzeFood(String input) async {
    final library = <String, FoodEntry>{
      'ovo': FoodEntry(id: _id(), name: 'Ovo', calories: 78, protein: 6, carbs: 0, fats: 5, createdAt: DateTime.now()),
      'frango': FoodEntry(id: _id(), name: 'Frango', calories: 165, protein: 31, carbs: 0, fats: 4, createdAt: DateTime.now()),
      'arroz': FoodEntry(id: _id(), name: 'Arroz', calories: 130, protein: 2, carbs: 28, fats: 0, createdAt: DateTime.now()),
      'banana': FoodEntry(id: _id(), name: 'Banana', calories: 105, protein: 1, carbs: 27, fats: 0, createdAt: DateTime.now()),
      'feijao': FoodEntry(id: _id(), name: 'Feijao', calories: 110, protein: 7, carbs: 20, fats: 1, createdAt: DateTime.now()),
      'whey': FoodEntry(id: _id(), name: 'Whey', calories: 120, protein: 24, carbs: 3, fats: 1, createdAt: DateTime.now()),
    };

    final lower = input.toLowerCase();
    final detected = library.entries
        .where((entry) => lower.contains(entry.key))
        .map((entry) => entry.value)
        .toList();

    final items = detected.isEmpty
        ? [
            FoodEntry(
              id: _id(),
              name: 'Refeicao estimada',
              calories: 350,
              protein: 18,
              carbs: 35,
              fats: 12,
              createdAt: DateTime.now(),
            )
          ]
        : detected;

    final analysis = FoodAnalysis(
      id: _id(),
      input: input,
      detectedItems: items,
      totalCalories: items.fold(0, (sum, item) => sum + item.calories),
      notes: detected.isEmpty
          ? 'Nenhum item reconhecido com precisao. Ajuste manualmente se necessario.'
          : 'Itens reconhecidos a partir do texto enviado.',
    );

    _state = _copyWith(analyses: [analysis, ..._state.analyses]);
    await _persist();
    return analysis;
  }

  Future<void> chooseStarter(String species, String nickname) async {
    _state = _copyWith(
      starter: StarterCreature(
        nickname: nickname.isEmpty ? 'Seu Inicial' : nickname,
        species: species,
        stage: 1,
        xp: 0,
        battlesWon: 0,
      ),
      battleLogs: [],
    );
    await _persist();
  }

  Future<String> captureCreature() async {
    final capturesAllowed = _state.dailyTrainingDates.toSet().length ~/ 3;
    if (_state.capturedSpecies.length >= capturesAllowed) {
      return 'Treine por mais dias para liberar uma nova captura.';
    }

    const pool = ['Pikachu', 'Machop', 'Eevee', 'Snorlax', 'Psyduck', 'Growlithe'];
    final species = pool[_state.capturedSpecies.length % pool.length];
    _state = _copyWith(capturedSpecies: [..._state.capturedSpecies, species]);
    await _persist();
    return '$species entrou para a sua colecao.';
  }

  AppState _copyWith({
    List<WorkoutPlan>? workoutPlans,
    List<FoodEntry>? foodEntries,
    List<FoodAnalysis>? analyses,
    List<VideoResource>? videos,
    int? todaySteps,
    int? calorieGoal,
    List<String>? dailyTrainingDates,
    StarterCreature? starter,
    List<String>? capturedSpecies,
    List<BattleLog>? battleLogs,
  }) {
    return AppState(
      workoutPlans: workoutPlans ?? _state.workoutPlans,
      foodEntries: foodEntries ?? _state.foodEntries,
      analyses: analyses ?? _state.analyses,
      videos: videos ?? _state.videos,
      todaySteps: todaySteps ?? _state.todaySteps,
      calorieGoal: calorieGoal ?? _state.calorieGoal,
      dailyTrainingDates: dailyTrainingDates ?? _state.dailyTrainingDates,
      starter: starter ?? _state.starter,
      capturedSpecies: capturedSpecies ?? _state.capturedSpecies,
      battleLogs: battleLogs ?? _state.battleLogs,
    );
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, _state.toJson());
    notifyListeners();
  }

  static AppState _defaultState() {
    final squat = WorkoutExercise(
      id: _id(),
      name: 'Agachamento Livre',
      sets: 4,
      reps: '10-12',
      restSeconds: 90,
      caloriesPerSet: 9,
      videoTitle: 'Execucao correta do agachamento livre',
      videoUrl: 'https://www.youtube.com/results?search_query=agachamento+livre+execucao+correta',
    );
    final bench = WorkoutExercise(
      id: _id(),
      name: 'Supino Reto',
      sets: 4,
      reps: '8-10',
      restSeconds: 90,
      caloriesPerSet: 8,
      videoTitle: 'Como fazer supino reto',
      videoUrl: 'https://www.youtube.com/results?search_query=supino+reto+execucao+correta',
    );
    final row = WorkoutExercise(
      id: _id(),
      name: 'Remada Curvada',
      sets: 4,
      reps: '10-12',
      restSeconds: 75,
      caloriesPerSet: 7,
      videoTitle: 'Remada curvada passo a passo',
      videoUrl: 'https://www.youtube.com/results?search_query=remada+curvada+execucao+correta',
    );

    return AppState(
      workoutPlans: [
        WorkoutPlan(
          id: _id(),
          name: 'Treino A',
          focus: 'Peito e Quadriceps',
          weekday: 'Segunda',
          exercises: [bench, squat],
          completedDates: [],
        ),
        WorkoutPlan(
          id: _id(),
          name: 'Treino B',
          focus: 'Costas',
          weekday: 'Quarta',
          exercises: [row],
          completedDates: [],
        ),
      ],
      foodEntries: [],
      analyses: [],
      videos: [
        VideoResource(id: _id(), exerciseName: squat.name, title: squat.videoTitle, category: 'Pernas', url: squat.videoUrl),
        VideoResource(id: _id(), exerciseName: bench.name, title: bench.videoTitle, category: 'Peito', url: bench.videoUrl),
        VideoResource(id: _id(), exerciseName: row.name, title: row.videoTitle, category: 'Costas', url: row.videoUrl),
      ],
      todaySteps: 4200,
      calorieGoal: 2200,
      dailyTrainingDates: [],
      starter: StarterCreature(nickname: 'Seu Inicial', species: 'Charmander', stage: 1, xp: 0, battlesWon: 0),
      capturedSpecies: [],
      battleLogs: [],
    );
  }

  static StarterCreature _evolve(StarterCreature starter) {
    if (starter.species == 'Charmander' && starter.xp >= 70 && starter.stage == 1) {
      return starter.copyWith(species: 'Charmeleon', stage: 2);
    }
    if (starter.species == 'Charmeleon' && starter.xp >= 140 && starter.stage == 2) {
      return starter.copyWith(species: 'Charizard', stage: 3);
    }
    if (starter.species == 'Bulbasaur' && starter.xp >= 70 && starter.stage == 1) {
      return starter.copyWith(species: 'Ivysaur', stage: 2);
    }
    if (starter.species == 'Ivysaur' && starter.xp >= 140 && starter.stage == 2) {
      return starter.copyWith(species: 'Venusaur', stage: 3);
    }
    if (starter.species == 'Squirtle' && starter.xp >= 70 && starter.stage == 1) {
      return starter.copyWith(species: 'Wartortle', stage: 2);
    }
    if (starter.species == 'Wartortle' && starter.xp >= 140 && starter.stage == 2) {
      return starter.copyWith(species: 'Blastoise', stage: 3);
    }
    return starter;
  }

  static String get _todayKey => _dateKey(DateTime.now());

  static String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static String _id() => DateTime.now().microsecondsSinceEpoch.toString();
}
